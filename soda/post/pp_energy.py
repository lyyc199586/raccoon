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
  "Fracture energy": pp["fracture_energy"],
  "Strain energy": pp["strain_energy"] + pp["strain_energy_p"],
  "Kinetic energy": pp["kinetic_energy"] + pp["kinetic_energy_p"],
}

# ax.stackplot(t, energy.values(), labels=energy.keys(), alpha=0.6)
# ax.plot(t, pp["external_work"], label="External work")
ax.plot(t, pp["fracture_energy"], label="Fracture energy")
# ax.plot(t, pp["strain_energy"], label="Strain energy (glass)")
# ax.plot(t, pp["strain_energy_p"], label="Strain energy (putty)")
# ax.plot(t, pp["kinetic_energy"], label="Kinetic energy (glass)")
# ax.plot(t, pp["kinetic_energy_p"], label="Kinetic energy (putty)")

ax.set_xlabel("Time ($\mu$s)")
ax.set_ylabel("Energy (mJ)")
ax.legend(loc='upper left')
# %%
# fig.savefig('./figure/pp_energy.png')
# fig.savefig('pp_fracture_energy.png')
# fig.savefig('pp_strain_energy.png')
# fig.savefig('pp_kinetic_energy.png')
# %%
