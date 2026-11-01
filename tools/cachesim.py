import argparse
import csv

from params import CACHE


class Cache:
    def __init__(self, size, line, ways, policy):
        self.line = line
        self.nlines = size // line
        self.ways = self.nlines if ways == 0 else ways
        self.nsets = self.nlines // self.ways
        self.policy = policy
        self.sets = [[] for _ in range(self.nsets)]
        self.seen = set()
        self.hits = 0
        self.misses = 0
        self.mem_reads = 0
        self.mem_writes = 0

    def split(self, addr):
        block = addr // self.line
        return block // self.nsets, block % self.nsets, addr % self.line, block

    def access(self, rw, addr):
        tag, index, word, block = self.split(addr)
        ways = self.sets[index]
        entry = next((e for e in ways if e["tag"] == tag), None)
        evicted = None
        before = block in self.seen
        hit = entry is not None
        if hit:
            self.hits += 1
            ways.remove(entry)
        else:
            self.misses += 1
            self.mem_reads += 1
            if len(ways) == self.ways:
                victim = ways.pop(0)
                evicted = victim["tag"] * self.nsets + index
                if victim["dirty"]:
                    self.mem_writes += 1
            entry = {"tag": tag, "dirty": False}
        ways.append(entry)
        self.seen.add(block)
        if rw == "W":
            if self.policy == "wt":
                self.mem_writes += 1
            else:
                entry["dirty"] = True
        return {
            "tag": tag,
            "index": index,
            "word": word,
            "hit": hit,
            "evicted": evicted,
            "before": before,
        }

    def snapshot(self):
        rows = []
        for index, ways in enumerate(self.sets):
            for lru, e in enumerate(ways):
                rows.append((index, e["tag"], e["dirty"], lru))
        return rows

    def dirty_blocks(self):
        return [e["tag"] * self.nsets + i for i, ways in enumerate(self.sets) for e in ways if e["dirty"]]

    @property
    def total(self):
        return self.hits + self.misses

    @property
    def ratio(self):
        return self.hits / self.total if self.total else 0.0


def load_trace(path):
    with open(path, newline="") as f:
        reader = csv.reader(f)
        rows = [r for r in reader if r and r[0].strip().isdigit()]
    return [(r[1].strip().upper(), int(r[2], 16)) for r in rows]


def run(trace, size, line, ways, policy, show=0):
    cache = Cache(size, line, ways, policy)
    table = []
    state = None
    for i, (rw, addr) in enumerate(trace, 1):
        info = cache.access(rw, addr)
        if i <= show:
            table.append((i, rw, addr, info))
        if i == show:
            state = cache.snapshot()
    return cache, table, state


def print_table(cache, table):
    label = "Line" if cache.ways == 1 else "Set"
    print(f"{'#':>3} {'R/W':>3} {'Address':>10} {'Tag':>9} {label:>4} {'Word':>4} {'H/M':>4} {'Evicted block':>14} {'Seen before':>11}")
    for i, rw, addr, info in table:
        ev = "-" if info["evicted"] is None else f"0x{info['evicted']:x}"
        print(f"{i:>3} {rw:>3} 0x{addr:08x} 0x{info['tag']:07x} {info['index']:>4} {info['word']:>4} {'H' if info['hit'] else 'M':>4} {ev:>14} {'yes' if info['before'] else 'no':>11}")


def print_state(cache, state):
    print("Set/Line  LRU(0=oldest)  Valid  Tag        Dirty")
    for index, tag, dirty, lru in state:
        d = ("1" if dirty else "0") if cache.policy == "wb" else "-"
        print(f"{index:>8} {lru:>13} {1:>6}  0x{tag:07x}  {d:>5}")


def summary(name, cache):
    print(f"{name}: refs={cache.total} hit={cache.hits} miss={cache.misses} H={cache.ratio:.4f} mem_writes={cache.mem_writes} mem_reads={cache.mem_reads}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("trace")
    ap.add_argument("--d", type=int)
    ap.add_argument("--size", type=int)
    ap.add_argument("--line", type=int)
    ap.add_argument("--ways", type=int, help="1 = direct, 0 = fully associative")
    ap.add_argument("--policy", choices=["wb", "wt"])
    ap.add_argument("--show", type=int, default=30)
    ap.add_argument("--sweep", action="store_true")
    a = ap.parse_args()
    if a.d is not None:
        size, line, ways = CACHE[a.d]
        a.size = a.size or size
        a.line = a.line or line
        a.ways = ways if a.ways is None else a.ways
        a.policy = a.policy or ("wb" if a.d % 2 == 0 else "wt")
    trace = load_trace(a.trace)
    cache, table, state = run(trace, a.size, a.line, a.ways, a.policy, a.show)
    print(f"Config: {a.size} B, {a.line} B line, ways={a.ways or 'full'}, sets={cache.nsets}, policy={a.policy}")
    print_table(cache, table)
    if state is not None:
        print(f"\nCache state after reference {a.show}:")
        print_state(cache, state)
        first = run(trace[: a.show], a.size, a.line, a.ways, a.policy)[0]
        summary(f"\nFirst {a.show}", first)
    summary("Full trace", cache)
    if a.policy == "wb":
        print("Dirty blocks left at end:", [hex(b) for b in cache.dirty_blocks()])
    if a.sweep:
        print("\nMapping sweep (line fixed):")
        for w in (1, 2, 4, 0):
            if w and a.size // a.line < w:
                continue
            c = run(trace, a.size, a.line, w, a.policy)[0]
            summary(f"  {'direct' if w == 1 else 'full' if w == 0 else f'{w}-way'}", c)
        print("Line size sweep (mapping fixed):")
        for ln in (8, 16, 32, 64):
            if a.size // ln < max(a.ways, 1):
                continue
            c = run(trace, a.size, ln, a.ways, a.policy)[0]
            summary(f"  {ln} B", c)


if __name__ == "__main__":
    main()
