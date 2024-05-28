# compare analytical J and K with discrete crack results

#%%
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# unit: MPa, mm, us
E = 32e3 # 32 GPa
nu = 0.2
rho = 2.45e3
h = 20
C = np.sqrt(E/rho)

# calc Rayleigh wave speed
Cs = np.sqrt(E/2/rho/(1+nu))
Cr = Cs*(0.862+1.14*nu)/(1+nu)

print(f"Cr={Cr}")

#%% plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

u_list = glob.glob('../gold/*V0.75*')
v_list = glob.glob('../gold/*u0.1*')

def line_plot(data_path, ax):
    # read data
    u0 = float(data_path.split('u')[1].split('_')[0])
    V = float(data_path.split('V')[1].split('_')[0])
    df = pd.read_csv(data_path)
    
    # calc G
    G = (u0/h)**2*h*E*(1 - (1-nu**2)*(V**2/C**2))/( 1 - V**2/C**2)
    
    ax.plot(df.time, df.DJint*2/G, label=f"$u_0={u0}, V={V}$")
    
for u_dir in sorted(u_list):
    line_plot(u_dir, ax1)
    
for v_dir in sorted(v_list):
    line_plot(v_dir, ax2)
    
for ax in (ax1, ax2):
    ax.hlines(1, 0, 160, color='k', ls='dashed')
    ax.set(xlabel='Time', ylabel='$J/G$', xlim=[0, 150], ylim=[0, 1.2])
    ax.legend()


# %%
fig.savefig("DJint_compare.png")
# %%
