# plot and generate tabular boundary conditions for cmrl input
#%%

import numpy as np
import matplotlib.pyplot as plt

def times(t_start, t_end, dt_initial, dt_final, steps):
    transition = np.logspace(np.log10(dt_initial), np.log10(dt_final), steps)
    
    # Accumulate time values from transition region
    times = [t_start]
    for dt in transition:
        if times[-1] + dt > t_end:
            break
        times.append(times[-1] + dt)
    
    # Add final time value if not included
    if times[-1] < t_end:
        times.append(t_end)

    return np.array(times)

def plot_line(ax, a, b, t):
    u = a*(1-np.exp(-b*t))
    ax.plot(t*1e6, u)
    ax.set(xlabel='Time, $t~(\mu$s)', ylabel='Displcacement, $u_y$ (mm)')
    print_bc(t, u)
    
def print_bc(times, disps):
    for t, u in zip(times, disps):
        print(f"{t:.2E}\t{u:.3E}")

# ts = times(0, 2e-4, 1e-6, 1e-6, 10)
# t = np.array([0,0.01,0.02,0.05,0.1,0.5,1])*2e-4
ts = np.linspace(0, 1, 10)*2e-4
a = 1.5e-2 # amplitude, mm
b = 2.4e4

fig, ax = plt.subplots()

plot_line(ax, a, b, ts)
fig.savefig("bc.png")
# %%
