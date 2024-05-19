
#%%
import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

csv_paths = glob.glob("../gold/pr_seed2_patch4*")

def sub1(ax, csv_path):
    df = pd.read_csv(csv_path)
    l = float(csv_path.split('l')[2].split('_')[0])
    ax.plot(df.time[1:], df.avg_p[1:], label=f'$l={l}$')

def sub2(ax, csv_path):
    df = pd.read_csv(csv_path)
    l = float(csv_path.split('l')[2].split('_')[0])
    ax.plot(df.time[1:], df.avg_p_over_p0[1:], label=f'$l={l}$')
    
t = np.linspace(0, 80, 21)
p0 = 400
t0 = 100
p = p0*np.exp(-t/t0)
# area = np.pi*80/2
ax1.plot(t, p, 'kx', label=r'Baseline $p$')


for csv_path in csv_paths:
    sub1(ax1, csv_path)
    sub2(ax2, csv_path)
    
ax1.set(xlim=[0, 50], ylim=[100, 450], xlabel='t', ylabel='$p$')
ax2.set(xlim=[0, 50], ylim=[0.5, 1.05], xlabel='t', ylabel='$p/p_0$')
    
ax1.legend()
ax2.legend()
# %%
