# compare analytical J and K with discrete crack results

#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# unit: MPa, mm, us
E = 32e3 # 32 GPa
nu = 0.2
rho = 2.45e3

h = 20
u0 = 0.1
V = 0.25
C = np.sqrt(E/rho)

G = (u0/h)**2*h*E*(1 - (1-nu**2)*(V**2/C**2))/( 1 - V**2/C**2)

fig, ax = plt.subplots()

df = pd.read_csv('../gold/steady_u0.1_V0.25_Tc60_Tf160.csv')

ax.plot(df.time, df.DJint*2, label='RACCOON')
ax.hlines([G], 0, 160, 'k', label='Analytical')

ax.set(xlabel='Time', ylabel='J')
ax.legend()

# %%
fig.savefig("DJint_u0.1_V0.25_Tc60_Tf160.png")
# %%
