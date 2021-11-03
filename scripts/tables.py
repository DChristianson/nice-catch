import math
from collections import Counter

def hpos(x):
    pulses = int(x / 15)
    r = x - pulses * 15
    if r < 8:
        hmove = 7 - r
    else:
        hmove = 15 - (r - 8)
    return (hmove * 16) + pulses 

def line(x, y):

    w = int(max(1.0, x / (y + 1.0)))
    steps = y + 1.0 if y < x else y / x
    if 0 == w:
        hmove = 0
    elif w < 8:
        hmove = 16 * (16 - w)
    else:
        hmove = 1

    dx = int(x)
    dy = int(y)
    D = 2 * dy - dx
    bham = []
    darr = []
    last_i = 0
    for i in range(0, x):
        darr.append(D)
        if D > 0:
            bham.append(i - last_i)
            last_i = i
            D = D - 2 * dx
        D = D + 2 * dy
    

    counts = sorted(Counter(bham).items(), key=lambda t: (-t[1], -t[0]))
    num_counts = len(counts)

    if num_counts == 0:
        a = num_a = b = num_b = 0
        err = 0
    elif num_counts == 1:
        a, num_a = counts[0]
        b = a
        num_a = 1
        num_b = 1
        err = 0
    else:
        a, num_a = counts[0]
        b, num_b = counts[1]
        period = int(num_a / (num_b + 1))
        err = x - (a * period * (num_b + 1)  + b * num_b)
        num_a = period
        num_b = 1
    
    print(x, y, steps, w, hmove, bham, a, num_a, b, num_b, err, darr)
    return (steps, w, hmove)

lo = 0
hi = 256
step = 2

height = 120.0
width = 32.0

rads = list([float(x) / 256.0 * math.pi / (2.0) for x in range(lo, hi, step)])

xpos = [round(math.cos(r) * width) for r in rads]
ypos = [round(math.sin(r) * height) for r in rads]
hpos = [hpos(x) for x in xpos]
vpos = ypos

lines = [line(x, y) for x, y in zip(xpos, ypos)]
steps = [l[0] for l in lines]
grp   = [l[1] for l in lines]
hmov  = [l[2] for l in lines]


print('RAD_2_HPOS\n    byte ' + ','.join([f'${hex(int(x))[2:]}' for x in hpos]))
print('RAD_2_VPOS\n    byte ' + ','.join([f'${hex(int(y))[2:]}' for y in vpos]))
print('RAD_2_STEPS\n    byte ' + ','.join([f'${hex(int(h))[2:]}' for h in steps]))
print('RAD_2_GRP\n    byte ' + ','.join([f'${hex(int(h))[2:]}' for h in grp]))
print('RAD_2_HMOV\n    byte ' + ','.join([f'${hex(int(h))[2:]}' for h in hmov]))

