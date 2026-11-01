import sys

from params import compute


def run(sid, n):
    x = sid & 0xFFFFFFFF
    data = []
    for _ in range(n):
        x = (1664525 * x + 1013904223) & 0xFFFFFFFF
        data.append((x >> 16) % 1000)
    original = list(data)
    desc = sid & 1
    swaps = 0
    for p in range(n - 1):
        for j in range(n - 1 - p):
            a, b = data[j], data[j + 1]
            if (a < b) if desc else (a > b):
                data[j], data[j + 1] = b, a
                swaps += 1
    return {
        "input": original,
        "sorted": data,
        "median": data[(n - 1) // 2],
        "min_v": min(data),
        "max_v": max(data),
        "swaps": swaps,
    }


if __name__ == "__main__":
    p = compute(sys.argv[1] if len(sys.argv) > 1 else "1306240183")
    r = run(p["SID"], p["N"])
    print("input :", r["input"])
    print("sorted:", r["sorted"])
    for key in ("median", "min_v", "max_v", "swaps"):
        print(f"{key} = {r[key]}")
