#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# load data
x = pd.read_csv("../gold/exp_tip_x.csv", header=None)
# r = pd.read_csv("../gold/exp_tip_r.csv", header=None)

df = pd.read_csv("../gold/tip_full_tip_p22.5_gc8.89e-3_ts30_cs330_l0.25_delta0.csv")



# plot
fig, ax = plt.subplots(figsize=(3.2, 2.655))

plt.style.use('elsevier.mplstyle')

ax.plot(x.iloc[:, 0]+27, x.iloc[:, 1]-26.08, 'x', label='exp')
ax.plot(df["tip_x"], df["tip_y"], label='sim')

ax.set_xlabel('$x$-axis')
ax.set_ylabel('$y$-axis')
ax.set_xlim([25, 86])
ax.set_ylim([-25, 25])
ax.legend()
# %%

fig.savefig('tip_trace.png')
# %%
