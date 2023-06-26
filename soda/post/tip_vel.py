#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.ndimage import uniform_filter1d

def plot_df(df, window_size, cR, color, label=''):
    t = df["time"]*1e6 # to us
    v = df["tip_velocity"]
    y = df["tip_y"]
    t0 = t.loc[df[v > 0].index[0]] # crack initiation time
    t1 = t.loc[df[y > 0.5].index[0]] # branch start time
    t2 = t.loc[df[y > 1].index[0]] # branch end time
    ax.plot(t - t0, uniform_filter1d(v, w)/cR, color=color, label=label)
    ax.axvspan(t1 - t0, t2 - t0, facecolor=color, alpha=0.1)


fig, ax = plt.subplots(figsize=(6.4, 2.655))
plt.style.use('elsevier.mplstyle')
# plt.tight_layout()

# experiement data
s1 = pd.read_csv("../gold/exp_s1.csv", header=None)
s2 = pd.read_csv("../gold/exp_s2.csv", header=None)

x1 = s1.iloc[:, 0]
y1 = s1.iloc[:, 1]

x2 = s2.iloc[:, 0]
y2 = s2.iloc[:, 1]

y_max = np.maximum(y1, y2)/3200
y_min = np.minimum(y1, y2)/3200
ax.fill_between(x1, y_min, y_max, facecolor='grey', alpha=0.6, label="Experiment")

# simulation
df1 = pd.read_csv("../gold/tip_full_p20_gc9e-3_ts30_cs330_l0.25_delta-0.625.csv")
df2 = pd.read_csv("../gold/tip_full_p25_gc9e-3_ts30_cs330_l0.25_delta-0.625.csv")
df3 = pd.read_csv("../gold/tip_full_p20_gc10e-3_ts30_cs330_l0.25_delta-0.55.csv")
df4 = pd.read_csv("../gold/tip_full_p25_gc10e-3_ts30_cs330_l0.25_delta-0.55.csv")

w = 10
cR = 3.2e6
# ax.plot(df1["time"]*1e6 - 15.45, uniform_filter1d(df1["tip_velocity"], w)/3.2e6, label='$G_c=9$ N/m, $p=20$ MPa')
# ax.plot(df2["time"]*1e6 - 14, uniform_filter1d(df2["tip_velocity"], w)/3.2e6, label='$G_c=9$ N/m, $p=25$ MPa')
# ax.plot(df3["time"]*1e6 - 15.7, uniform_filter1d(df3["tip_velocity"], w)/3.2e6, label='$G_c=10$ N/m, $p=20$ MPa')
# ax.plot(df4["time"]*1e6 - 14.15, uniform_filter1d(df4["tip_velocity"], w)/3.2e6, label='$G_c=10$ N/m, $p=25$ MPa')
# colors = ax._get_lines.color_cycle
colors = ['#c1272d', '#0000a7', '#eecc16', '#008176', "#b3b3b3"]
dfs = [df1, df2, df3, df4]
plot_df(dfs[0], w, cR, colors[0], label="$G_c=9$ N/m, $p=20$ MPa")
plot_df(dfs[1], w, cR, colors[1], label="$G_c=9$ N/m, $p=25$ MPa")
plot_df(dfs[2], w, cR, colors[2], label="$G_c=10$ N/m, $p=20$ MPa")
plot_df(dfs[3], w, cR, colors[3], label="$G_c=10$ N/m, $p=25$ MPa")

ax.set_xlim([0, 50])
ax.set_ylim([0, 0.8])
ax.set_xlabel("Time ($\\mu$s)")
ax.set_ylabel("Normalized crack velocity $v/c_R$")
ax.legend()
# %%

fig.savefig('tip_vel_w10.png')
# %%
