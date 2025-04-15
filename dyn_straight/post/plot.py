#%%
import matplotlib.pyplot as plt
import pandas as pd
import glob
import cm_vis

csv_files = glob.glob('../gold/**/**.csv')

def line(axs, csv_file):
    df = pd.read_csv(csv_file)
    axs[0][0].plot(df['time'], df['external_work'])
    axs[0][0].set(ylabel="External work, $W_e$ (\si{\milli\joule})")
    axs[0][1].plot(df['time'], df['strain_energy'])
    axs[0][1].set(ylabel="Strain energy, $\Psi_e$ (\si{\milli\joule})")
    axs[1][0].plot(df['time'], df['kinetic_energy'])
    axs[1][0].set(ylabel="Kinetic energy, $\Psi_k$ (\si{\milli\joule})")
    
    fracture_energy = df['external_work'] - df['strain_energy'] - df['kinetic_energy']
    axs[1][1].plot(df['time'], fracture_energy)
    axs[1][1].set(ylabel="Dissipated energy, $\Psi_f$ (\si{\milli\joule})")

plt.style.use('sans')
fig, axs = plt.subplots(2, 2, figsize=(7, 5))


for csv_file in csv_files:
    line(axs, csv_file)
    
for ax in axs.flatten():
    ax.set(xlabel=r"Time, $t$ (\si{\micro\second})")
    
fig.legend(["$l=0.625$ \si{\milli\meter}", "$l=0.5$ \si{\milli\meter}", "$l=0.375$ \si{\milli\meter}"], loc="outside upper center", ncols=3)


# %%
fig.savefig('energies.png')

# %%
