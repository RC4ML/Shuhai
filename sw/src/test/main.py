# /*
#  * Copyright 2019 - 2020, RC4ML, Zhejiang University
#  *
#  * This hardware operator is free software: you can redistribute it and/or
#  * modify it under the terms of the GNU General Public License as published
#  * by the Free Software Foundation, either version 3 of the License, or
#  * (at your option) any later version.
#  *
#  * This program is distributed in the hope that it will be useful,
#  * but WITHOUT ANY WARRANTY; without even the implied warranty of
#  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  * GNU General Public License for more details.
#  *
#  * You should have received a copy of the GNU General Public License
#  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  */
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
