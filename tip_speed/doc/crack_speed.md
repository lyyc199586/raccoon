# Dynamic energy release rate and crack tip speed

## Crack tip velocity?

Consider (5.9)

$$
\frac{1+\nu}{E} \frac{V^2 \alpha_d}{C_s^2R(V)} \left[k(V)K_I^0(t, l(t),0)\right]^2 = G
$$

$E, \nu$: Young's modulus, Poisson's ratio
$V$: crack tip speed
$C_d$: dilatational wave speed $C_d=\sqrt{\dfrac{\lambda+2\mu}{\rho}}$
$C_s$: shear wave speed $C_s=\sqrt{\dfrac{\mu}{\rho}}$
$C_R$: Rayleigh wave speed $C_R = C_s\sqrt{\dfrac{0.862+1.14\nu}{1+\nu}}$
$\alpha_d$: $\alpha_d=\sqrt{1-\dfrac{V^2}{C_d^2}}$ 
$\alpha_s$: $\alpha_s=\sqrt{1-\dfrac{V^2}{C_s^2}}$ 
$R(V)$: Rayleigh function $R(V)=4\alpha_d\alpha_s-(1+\alpha_s^2)^2$
$k(V)$: the universal function $k(V)\approx \dfrac{1-V/C_R}{\sqrt{1-V/C_d}}$
$K_I^0(t, l(t), 0)$: the static stress intensity factor

It has the form:

See P45, and (5.3.10) in L.B. Freund (only consider mode I)
$$
G = \frac{1-\nu^2}{E} A_I(V)K_I^2,
$$

where

$$
A_I(V) = \frac{V^2 \alpha_d}{(1-\nu)C_s^2 D}, D =4\alpha_d\alpha_s-(1+\alpha_s^2)^2
$$

---

### Dynamic $K$ for moving cracks

(4.56)

$$
K_I(t, l, \dot{l})=k(V)K_I^0(t, l, 0),
$$

where $K_I^0(t,l,0)$ is the stress intensity factor corresponding to a **stationary** crack of length $l$, we can use static $J$-integral to calculate static $G$, then use

$$
G = \frac{(K_I^0)^2}{E'},
$$

where $E'=E$ for plane stress, $E'=E/(1-\nu^2)$ for plane strain.

If we have $K_I^0=K_{Ic}$, then $G = G_c^0$
<!-- we can eliminate $G$ and $K_I^0$ in (5.9) (use plane stress for example):

$$
(1+\nu) \frac{V^2 \alpha_d}{C_s^2R(V)} k(V)^2 = 1
$$

In this case, $V$ is  -->



### Verify Dynamic $G$ from (5.9)

(5.9)

$$
\frac{1+\nu}{E} \frac{V^2 \alpha_d}{C_s^2R(V)} \left[k(V)K_I^0(t, l(t),0)\right]^2 = G
$$

We can use quasistatic $G^0$ as input (from static $J$ integral)

so that $(K_I^0)^2 = G^0 E/(1-\nu^2)$, (5.9) can be simplified to 

$$
\frac{V^2 \alpha_d}{C_s^2R(V)} \frac{k^2(V)}{1-\nu} G_0 = G
$$

We can set a constant $V$, and use static J integral to compute $G_0$ and so the LHS, and the dynamic J integral which gives the RHS.

