import matplotlib.pyplot as plt

x, y = [], []
with open('derivative.dat', 'r') as file:
    for line in file:
        tup = line.strip().split('\t\t')
        x.append(float(tup[0])), y.append(float(tup[1]))

x.sort(); y.sort()

plt.plot(x, y, 'bo-')
plt.show()
