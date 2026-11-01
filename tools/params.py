import sys

CACHE = {
    0: (128, 16, 1),
    1: (128, 16, 2),
    2: (256, 16, 1),
    3: (256, 32, 2),
    4: (128, 8, 4),
    5: (256, 16, 4),
    6: (64, 16, 1),
    7: (128, 32, 1),
    8: (256, 8, 2),
    9: (128, 16, 4),
}


def log2(x):
    return x.bit_length() - 1


def compute(sid_text):
    digits = [int(c) for c in sid_text]
    d = digits[-1]
    d2 = int(sid_text[-2:])
    s = sum(digits)
    sid = int(sid_text)
    if sid > 2**31 - 1:
        sid = int(sid_text[-9:])
    size, line, ways = CACHE[d]
    lines = size // line
    sets = lines // ways
    w = log2(line)
    index_bits = log2(sets)
    return {
        "SID_text": sid_text,
        "SID": sid,
        "d": d,
        "D2": d2,
        "S": s,
        "N": 24 + d2 % 25,
        "cache_size": size,
        "line_size": line,
        "ways": ways,
        "mapping": "direct" if ways == 1 else f"{ways}-way set-assoc",
        "lines": lines,
        "sets": sets if ways > 1 else None,
        "write_policy": "write-back" if d % 2 == 0 else "write-through",
        "k": s % 7 + 3,
        "interrupt": "Timer" if s % 2 == 0 else "I/O",
        "f_GHz": round(1.0 + 0.1 * d, 1),
        "T1": 1,
        "T2": 20 + 5 * (d % 4),
        "Nc": 2 + s % 7,
        "sort_dir": "ascending" if sid % 2 == 0 else "descending",
        "word_bits": w,
        "index_bits": index_bits,
        "tag_bits": 32 - index_bits - w,
    }


def report(p):
    s_steps = " + ".join(p["SID_text"])
    print(f"SID           = {p['SID_text']}  (const int SID = {p['SID']};)")
    print(f"d             = {p['d']}")
    print(f"D2            = {p['D2']:02d}")
    print(f"S             = {s_steps} = {p['S']}")
    print(f"N             = 24 + ({p['D2']} mod 25) = 24 + {p['D2'] % 25} = {p['N']}")
    sets = p["sets"] if p["sets"] else "-"
    print(f"Cache         = {p['cache_size']} B / {p['line_size']} B line / {p['mapping']} / {p['lines']} lines / sets {sets}")
    print(f"Write policy  = d={p['d']} {'even' if p['d'] % 2 == 0 else 'odd'} -> {p['write_policy']}")
    print(f"k             = ({p['S']} mod 7) + 3 = {p['S'] % 7} + 3 = {p['k']}")
    print(f"Interrupt     = S={p['S']} {'even' if p['S'] % 2 == 0 else 'odd'} -> {p['interrupt']}")
    print(f"f             = 1.0 + 0.1 x {p['d']} = {p['f_GHz']} GHz (assumption)")
    print(f"T1 / T2       = 1 cycle / 20 + 5 x ({p['d']} mod 4) = {p['T2']} cycle (assumption)")
    print(f"Nc            = 2 + ({p['S']} mod 7) = {p['Nc']} (assumption)")
    print(f"G4 direction  = SID {'even' if p['SID'] % 2 == 0 else 'odd'} -> {p['sort_dir']}")
    label = "line (r)" if p["ways"] == 1 else "set (d)"
    print(f"Address       = tag {p['tag_bits']} | {label} {p['index_bits']} | word {p['word_bits']} = 32 bits")


if __name__ == "__main__":
    report(compute(sys.argv[1] if len(sys.argv) > 1 else "1306240183"))
