import math
from collections import Counter


def line(x, y):
    inv = y  >  x
    if inv:
        tmp = x
        x = y
        y = tmp

    arr = [0] * 8
    dx = int(x)
    dy = int(y)
    D = 2 * dy - dx
    j = 0
    for i in range(0, x + 1):
        arr[j] |= 1 << (7 - i)
        if D > 0:
            j += 1
            D = D - 2 * dx
        D = D + 2 * dy

    if inv:
        flp = [0] * 8
        for i in range(0, 8):
            mask = 1 << (7 - i)
            for j in range(0, 8):
                if arr[j] & mask > 0:
                    flp[i] |= 1 << (7 - j)
        arr = flp

    return arr


coords = [(7, y) for y in range(0, 8)] + [(x, 7) for x in range(0, 7)]

for x, y in coords:
    arr = line(x, y)
    print(x, y)
    for i in arr:
        v = bin(i)[2:]
        v = '0' * (8 - len(v)) + v
        print(v)
