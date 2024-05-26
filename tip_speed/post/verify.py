#%%
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# unit: MPa, mm, us
E = 32e3 # 32 GPa
nu = 0.2
mu = E/2/(1+nu)
lbda = E*nu/(1+nu)/(1-2*nu)
rho = 2.45e3

Cd = np.sqrt((lbda+2*mu)/rho)
Cs = np.sqrt(mu/rho)
Cr = Cs*(0.862+1.14*nu)/(1+nu)

data_lists = glob.glob('../../dynamic_Jint/gold/*')
v = np.linspace(0, Cr, 100)

def calc_f(v):
    # calc f(v)
    a_d = np.sqrt(1 - v**2/Cd**2)
    a_s = np.sqrt(1 - v**2/Cs**2)
    D = 4*a_d*a_s - (1 + a_s**2)**2
    k = (1 - v/Cr)/np.sqrt(1 - v/Cd)
    A = v**2*a_d/((1-nu)*Cs**2*D)
    factor = A*k**2
    return factor

# def line_plot(data_path, ax):
#     #read data
#     u0 = float(data_path.split('u')[1].split('_')[0])
#     V = float(data_path.split('V')[1].split('_')[0])
#     df = pd.read_csv(data_path)
    
#     # calc LHS
#     a_d = np.sqrt(1 - V**2/Cd**2)
#     a_s = np.sqrt(1 - V**2/Cs**2)
#     D = 4*a_d*a_s - (1 + a_s**2)**2
#     k = (1 - V/Cr)/np.sqrt(1 - V/Cd)
#     A = V**2*a_d/(1-nu)/Cs**2/D
#     factor = A*k**2
    
#     print(f"u_0={u0}, V={V}, factor={factor}")
#     ax.plot(df.time, (df.DJint/(df.Jint*factor)), label=f"$u_0={u0}, V={V}$")

def point_plot(data_path, ax):
    u0 = float(data_path.split('u')[1].split('_')[0])
    V = float(data_path.split('V')[1].split('_')[0])
    df = pd.read_csv(data_path)
    ax.plot(V/Cr, df.DJint.iloc[-1]/df.Jint.iloc[-1], 'o', mfc='none', label=f"$u_0={u0}, V={V}$")
    
fig, ax = plt.subplots()

# for data_path in sorted(data_lists):
#     # line_plot(data_path, ax)
#     point_plot(data_path, ax)

ax.plot(v/Cr, calc_f(v), 'k--', label='$f(V)$')
ax.plot(v/Cr, 1 - v/Cr, 'blue', label='$1-\dot{l}/C_R$')

ax.set(xlabel='$V/C_R$', ylabel='$G/G_0$')
ax.legend(loc='best')

# %%
fig.savefig('factor.png')
# %%
