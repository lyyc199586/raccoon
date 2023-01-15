# Axisymmetric simulations for dynamic impact

![](./figures/illu.png)

## objective
study the **fatigure model** with multiple dynamic impacts

## configuration

domain: $r\times z=[0, 3.25]\times [-1,1]$ mm, time: $t\in[t_0, t_f], t_f=2$ ms.
velocity condtion: $\dot{u_z}(r, t)=T(t)\times R(r)$ on $[0, 0.375]\times(z=1)$,
where 
1) constant in time and space: $T(t)=v_0, R(r)=1$, yield $u_z = v_0t$
2) linearly decrease in time, constant in space: 
   
$$
  T(t)= \begin{cases}
    v_0 (1 - 10t/t_f), \text{ if } t<0.1 t_f\\
    0, \text{ else }
  \end{cases},
  R(r)=1,
  u_z = \begin{cases}
    v_0(t - 5t^2/t_f), \text{ if } t<0.1 t_f\\
    0.05v_0 t_f, \text{ else }
  \end{cases}
$$

3) smoothed

$$
  R(r)=\begin{cases}
    1, \text{ if } r<0.25\\
    0.5\left\{1+\cos[\pi/0.125 (r-0.25)]\right\}, \text{ else }
  \end{cases}
$$

![](./figures/velocity_profile.png)

boundary conditon: $u_z=0$ on bottom, $u_r=0$ on left (axial) 

## material properties

unit: mm, MPa, s
```python
E=6.16e3 #^
nu=0.2
psic=8.1e-3 #^ sigma_ts=10
Gc=3.656e-2
rho_s=1.995e-3 #[Mg/mm^3]
l= 0.25 #^ l_ch = 2.25
```

> (^): newly updated with BegoStone experiments

where $c_p=2276$ mm/s is the p wave speed
$$
c_p=\sqrt{\lambda+2 \mu \over \rho},\\
\lambda = {E\nu \over (1+\nu)(1-2\nu) },\\
\mu = G = {E\over 2(1+2\nu)}.
$$

mesh size $h>c_p\times \Delta t$ ?

## time integrator

use HHT-alpha instead of central difference