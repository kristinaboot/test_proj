L = [100, 180, 50, 45, 150]
k = 4

parts = [[x, 1] for x in L]

for _ in range(k):
    max_value = 0
    max_index = 0

    for i in range(len(parts)):
        current = parts[i][0] / parts[i][1]

        if current > max_value:
            max_value = current
            max_index = i

    parts[max_index][1] += 1

result = []

for length, cnt in parts:
    base = length // cnt
    rest = length % cnt

    for i in range(cnt):
        if i < rest:
            result.append(base + 1)
        else:
            result.append(base)

print(result)