#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# load data
x = pd.read_csv("../gold/exp_tip_x.csv", header=None)
# r = pd.read_csv("../gold/exp_tip_r.csv", header=None)

df1 = pd.read_csv("../gold/tip_full_p20_gc9e-3_ts30_cs330_l0.25_delta-0.625.csv")
df2 = pd.read_csv("../gold/tip_full_p25_gc9e-3_ts30_cs330_l0.25_delta-0.625.csv")
df3 = pd.read_csv("../gold/tip_full_p20_gc10e-3_ts30_cs330_l0.25_delta-0.55.csv")
df4 = pd.read_csv("../gold/tip_full_p25_gc10e-3_ts30_cs330_l0.25_delta-0.55.csv")



# plot
fig, ax = plt.subplots(figsize=(3.2, 2.655))

plt.style.use('elsevier.mplstyle')
plt.tight_layout()

colors = ['#c1272d', '#0000a7', '#eecc16', '#008176', "#b3b3b3"]
ax.plot(x.iloc[:, 0]+27, x.iloc[:, 1]-26.08, 'x', label='Experiment', color='grey')
ax.plot(df1["tip_x"], df1["tip_y"], label='$G_c=9$ N/m, $p=20$ MPa', color=colors[0])
ax.plot(df2["tip_x"], df2["tip_y"], label='$G_c=9$ N/m, $p=25$ MPa', color=colors[1])
ax.plot(df3["tip_x"], df3["tip_y"], label='$G_c=10$ N/m, $p=20$ MPa', color=colors[2])
ax.plot(df4["tip_x"], df4["tip_y"], label='$G_c=10$ N/m, $p=25$ MPa', color=colors[3])

ax.set_xlabel('$x$-axis')
ax.set_ylabel('$y$-axis')
ax.set_xlim([25, 86])
ax.set_ylim([-25, 25])
ax.legend()
# %%

fig.savefig('tip_trace.png')
# %%
