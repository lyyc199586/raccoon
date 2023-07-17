# post processing energy analysis

#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np 

fig, ax = plt.subplots(figsize=(3.2, 1.6))
plt.style.use('elsevier.mplstyle')

pp = pd.read_csv("../gold/pp_half_tan_p25_gc9e-3_ts30_cs330_l0.25_delta-0.625.csv")

t = pp["time"]*1e6
energy = {
  "Strain energy": pp["strain_energy"],
  "Kinetic energy": pp["kinetic_energy"],
  "Fracture energy": pp["fracture_energy"],
}

ax.stackplot(t, energy.values(), labels=energy.keys(), alpha=0.8)
ax.plot(t, pp["external_work"], label="External work")
# ax.plot(t, pp["fracture_energy"])

ax.set_xlabel("Time ($\mu$s)")
ax.set_ylabel("Fracture energy (mJ)")
ax.legend()
# %%
fig.savefig('pp_energy.png')
# %%
