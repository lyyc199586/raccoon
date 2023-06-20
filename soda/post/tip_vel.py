#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def smooth(data, window_size):
    return np.convolve(data, np.ones(window_size)/window_size, mode='same')

fig, ax = plt.subplots(figsize=(6.4, 2.655))
plt.style.use('elsevier.mplstyle')

# experiement data
s1 = pd.read_csv("../gold/exp_s1.csv", header=None)
s2 = pd.read_csv("../gold/exp_s2.csv", header=None)

x1 = s1.iloc[:, 0]
y1 = s1.iloc[:, 1]

x2 = s2.iloc[:, 0]
y2 = s2.iloc[:, 1]

y_max = np.maximum(y1, y2)/3200
y_min = np.minimum(y1, y2)/3200
ax.fill_between(x1, y_min, y_max, facecolor='grey', alpha=0.8, label="exp")

# simulation
df = pd.read_csv("../gold/tip_full_tip_p22.5_gc8.89e-3_ts30_cs330_l0.25_delta0.csv")
smooth_y = smooth(df["tip_velocity"], 10)
ax.plot(df["time"]*1e6 - 15, smooth_y/3.2e6, label="sim")

ax.set_xlim([0, 50])
ax.set_ylim([0, 0.8])
ax.set_xlabel("Time ($\mu$s)")
ax.set_ylabel("Normalized crack velocity $v/c_R$")
ax.legend()
# %%

fig.savefig('tip_vel.png')
# %%
