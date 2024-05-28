#%%
import numpy as np
import matplotlib.pyplot as plt

nu = 0.2
v = np.linspace(0, 0.99, 100)
g = (1-(1-nu**2)*v**2)/(1 - v**2)

fig, ax = plt.subplots()
ax.plot(v, g)

ax.set(xlabel="$V/C_o$", ylabel="$G$")
# %%
fig.savefig("g_to_v.png")
# %%
