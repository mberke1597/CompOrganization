import argparse
import csv
import os
import struct
import subprocess
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ADDR2LINE = os.path.join(ROOT, "toolchain", "xpack-riscv-none-elf-gcc-15.2.0-1", "bin", "riscv-none-elf-addr2line")
STACK_BASE = 0x70000000
MASK = 0xFFFFFFFF


def sx(v, bits):
    v &= (1 << bits) - 1
    return v - (1 << bits) if v >> (bits - 1) else v


def s32(v):
    return sx(v, 32)


class Memory:
    def __init__(self):
        self.bytes = {}

    def load(self, addr, size):
        return sum(self.bytes.get(addr + i, 0) << (8 * i) for i in range(size))

    def store(self, addr, size, value):
        for i in range(size):
            self.bytes[addr + i] = (value >> (8 * i)) & 0xFF


def load_elf(path, mem):
    with open(path, "rb") as f:
        elf = f.read()
    entry, phoff = struct.unpack_from("<II", elf, 0x18)
    phentsize, phnum = struct.unpack_from("<HH", elf, 0x2A)
    for i in range(phnum):
        ptype, off, vaddr, _, filesz, memsz = struct.unpack_from("<IIIIII", elf, phoff + i * phentsize)
        if ptype == 1:
            for j in range(memsz):
                mem.bytes[vaddr + j] = elf[off + j] if j < filesz else 0
    shoff = struct.unpack_from("<I", elf, 0x20)[0]
    shentsize, shnum, shstrndx = struct.unpack_from("<HHH", elf, 0x2E)
    sections = [struct.unpack_from("<IIIIIIIIII", elf, shoff + i * shentsize) for i in range(shnum)]
    symbols = {}
    for sh in sections:
        if sh[1] == 2:
            strtab = sections[sh[6]]
            for k in range(sh[5] // 16):
                name_off, value, _, _, _, _ = struct.unpack_from("<IIIBBH", elf, sh[4] + k * 16)
                end = elf.index(b"\0", strtab[4] + name_off)
                name = elf[strtab[4] + name_off:end].decode()
                if name:
                    symbols[name] = value
    return entry, symbols


def classify(op, f3, f7):
    if op == 0x03:
        return "load"
    if op == 0x23:
        return "store"
    if op in (0x63, 0x6F, 0x67):
        return "branch/jump"
    if op == 0x33 and f7 == 1:
        return "mul"
    return "alu"


def run(path, max_steps=10_000_000):
    mem = Memory()
    pc, symbols = load_elf(path, mem)
    x = [0] * 32
    log = []
    trace = []
    for step in range(max_steps):
        ins = mem.load(pc, 4)
        op = ins & 0x7F
        rd = (ins >> 7) & 0x1F
        f3 = (ins >> 12) & 7
        rs1 = (ins >> 15) & 0x1F
        rs2 = (ins >> 20) & 0x1F
        f7 = ins >> 25
        a, b = x[rs1], x[rs2]
        imm_i = sx(ins >> 20, 12)
        nxt = (pc + 4) & MASK
        res = None
        mem_ref = None
        if op == 0x37:
            res = ins & 0xFFFFF000
        elif op == 0x17:
            res = (pc + (ins & 0xFFFFF000)) & MASK
        elif op == 0x6F:
            imm = sx(((ins >> 31) << 20) | (((ins >> 12) & 0xFF) << 12) | (((ins >> 20) & 1) << 11) | (((ins >> 21) & 0x3FF) << 1), 21)
            res, nxt = nxt, (pc + imm) & MASK
        elif op == 0x67:
            res, nxt = nxt, (a + imm_i) & ~1 & MASK
        elif op == 0x63:
            imm = sx(((ins >> 31) << 12) | (((ins >> 7) & 1) << 11) | (((ins >> 25) & 0x3F) << 5) | (((ins >> 8) & 0xF) << 1), 13)
            taken = {0: a == b, 1: a != b, 4: s32(a) < s32(b), 5: s32(a) >= s32(b), 6: a < b, 7: a >= b}[f3]
            if taken:
                nxt = (pc + imm) & MASK
        elif op == 0x03:
            addr = (a + imm_i) & MASK
            size = {0: 1, 1: 2, 2: 4, 4: 1, 5: 2}[f3]
            v = mem.load(addr, size)
            res = v if f3 >= 4 else sx(v, size * 8) & MASK
            mem_ref = ("R", addr, size)
        elif op == 0x23:
            addr = (a + sx(((ins >> 25) << 5) | ((ins >> 7) & 0x1F), 12)) & MASK
            size = {0: 1, 1: 2, 2: 4}[f3]
            mem.store(addr, size, b)
            mem_ref = ("W", addr, size)
        elif op == 0x13:
            sh = (ins >> 20) & 0x1F
            res = {
                0: a + imm_i,
                1: a << sh,
                2: int(s32(a) < imm_i),
                3: int(a < (imm_i & MASK)),
                4: a ^ (imm_i & MASK),
                5: (s32(a) >> sh) if f7 == 0x20 else (a >> sh),
                6: a | (imm_i & MASK),
                7: a & (imm_i & MASK),
            }[f3] & MASK
        elif op == 0x33 and f7 == 1:
            sa, sb = s32(a), s32(b)
            if f3 == 0:
                res = sa * sb
            elif f3 == 1:
                res = (sa * sb) >> 32
            elif f3 == 2:
                res = (sa * b) >> 32
            elif f3 == 3:
                res = (a * b) >> 32
            elif f3 == 4:
                res = -1 if sb == 0 else int(sa / sb)
            elif f3 == 5:
                res = MASK if b == 0 else a // b
            elif f3 == 6:
                res = sa if sb == 0 else sa - sb * int(sa / sb)
            else:
                res = a if b == 0 else a % b
            res &= MASK
        elif op == 0x33:
            sh = b & 0x1F
            res = {
                (0, 0): a + b, (0, 0x20): a - b, (1, 0): a << sh, (2, 0): int(s32(a) < s32(b)),
                (3, 0): int(a < b), (4, 0): a ^ b, (5, 0): a >> sh, (5, 0x20): s32(a) >> sh,
                (6, 0): a | b, (7, 0): a & b,
            }[(f3, f7)] & MASK
        elif op == 0x73:
            break
        else:
            raise RuntimeError(f"unsupported instruction 0x{ins:08x} at 0x{pc:08x}")
        log.append((pc, ins, classify(op, f3, f7)))
        if mem_ref:
            trace.append((len(log), pc) + mem_ref)
        if res is not None and rd:
            x[rd] = res & MASK
        pc = nxt
    return mem, symbols, log, trace


def source_lines(elf, pcs):
    pcs = sorted(set(pcs))
    out = subprocess.run([ADDR2LINE, "-e", elf] + [hex(p) for p in pcs], capture_output=True, text=True).stdout.splitlines()
    return {p: (line.rsplit(":", 1)[-1].split()[0] if ":" in line else "?") for p, line in zip(pcs, out)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("elf")
    ap.add_argument("--trace", help="write data address trace CSV")
    ap.add_argument("--log", help="write executed instruction log CSV")
    a = ap.parse_args()
    mem, symbols, log, trace = run(a.elf)
    print(f"Executed instructions Ic = {len(log)}")
    for cls, n in sorted(Counter(c for _, _, c in log).items()):
        print(f"  {cls:12} {n}")
    for name in ("median", "min_v", "max_v", "swaps"):
        addr = symbols[name]
        print(f"{name:7} @ 0x{addr:08x} = {s32(mem.load(addr, 4))}")
    loads = sum(1 for t in trace if t[2] == "R")
    stack = sum(1 for t in trace if t[3] >= STACK_BASE)
    print(f"Data refs = {len(trace)} (loads {loads}, stores {len(trace) - loads}, stack {stack})")
    lines = source_lines(a.elf, [pc for pc, _, _ in log])
    if a.trace:
        with open(a.trace, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["sira", "RW", "adres_hex", "boyut", "c_satiri", "stack_mi"])
            for i, (_, pc, rw, addr, size) in enumerate(trace, 1):
                w.writerow([i, rw, f"{addr:08x}", size, lines[pc], int(addr >= STACK_BASE)])
    if a.log:
        with open(a.log, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["n", "pc", "word", "class", "c_line"])
            for i, (pc, ins, cls) in enumerate(log, 1):
                w.writerow([i, f"{pc:08x}", f"{ins:08x}", cls, lines[pc]])


if __name__ == "__main__":
    main()
