# Verify dynamic J integral

## Analytical solution: Steady moving crack

p244 Fig 5.5

![setup](setup.png)

Steady crack growth at speed $V$ in a strip of width $2h$, uniform normal displacement $u_0$ on top and bottom:
$$
u_2 (x_1, \pm h, t) = \pm u_0
$$

The stress intensity factor is
$$
K(t) = \frac{u_0 E}{\sqrt{h(1-\nu^2)}A_I(V)},
$$

where $A_I = \dfrac{V^2\alpha_d}{(1-\nu)C_s^2 D}$, $D =4\alpha_d\alpha_s-(1+\alpha_s^2)^2$

The energy release rate is

$$
G = \varepsilon_0^2 h E \frac{1-(1-\nu^2)V^2/C_o^2}{1- V^2/C_o^2},
$$
where $\varepsilon_0 = u_0/h, C_o=\sqrt{E/\rho}$, $V$ is less than $C_R$.

## Discrete crack

Use dynamic J integral on the discrete crack, using material properties and geometry from the dynamic branching problem, let $V=0.25$ (mm/$\mu$s), $u_0=0.05$ mm

$h = 20$ mm

![](../post/DJint_u0.1_V0.25_Tc60_Tf160.png)

