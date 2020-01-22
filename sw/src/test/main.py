#%%
import numpy as np 
from matplotlib import pyplot as plt 

path = "/home/ccai/distributed-accelerator-os/sw/src/test/res.txt"

#%%
def load_data(path):
    f = open(path,"r")
    res = f.readlines()
    for i in range(len(res)):
        res[i] = res[i].strip('\n') 
        res[i] = float(res[i])
    return res

def draw(data):
    x = np.arange(len(data))
    plt.title("data")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.scatter(x,data,s=1,c="gray")
    plt.show()

def count_time(data):
    count = {}
    for dot in data:
        if dot in count.keys():
            count[dot] += 1
        else:
            count[dot] = 1
    count = [(key,count[key]) for key in sorted(count.keys())]
    return count

def calculate_refresh_interval(data):
    time = 0
    num = 0
    total = 0
    for dot in data:
        time += 1
        if dot > 100:
            total += time
            time = 0
            num += 1
    return total/num

#%%
data = load_data(path)
draw(data)
res = count_time(data)
print(res)
print(calculate_refresh_interval(data))
# %%
