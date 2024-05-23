# Dynamic energy release rate and crack tip speed

## Static 

### G

Energy release rate: loss of total potential energy per unit crack growth area (length) $s$

$$
G=-\frac{\partial\Pi}{\partial s},
$$

where the total potential energy is

$$
\Pi = W - \int_{\partial\Omega} t\cdot u \;dS - \int_{\Omega} b\cdot u \;dV,
$$

$W$ is total strain energy.

### J integral

J integral is defined on any path $\Gamma$ starting and ending on the crack faces as

$$
J = \int_{\Gamma} \left(\psi_e n_1 - t \cdot \frac{\partial u}{\partial x_1}\right) \; d\Gamma,
$$

or

$$
J = \int_{\Gamma} \left( \frac{1}{2} \sigma_{ij} u_{i,j} n_1 - \sigma_{ij}n_j u_{i,1}\right) \; d\Gamma
$$

where $n_1$ is the $x_1$ component of unit vector normal to $\Gamma$.

In RACCOON, J is computed through given boundaries (should be around the crack tip), crack direction (tangential vector), and displacements

```cpp
// _t = {n1, n2, n3}
// _grad_disp = {grad_u1, grad_u2, grad_u3}
// _stress
// _psie

// assign grad u to RankTwoTensor
auto H = RankTwoTensor::initializeFromRows(
      (*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
RankTwoTensor I2(RankTwoTensor::initIdentity);

// calculate J
ADRankTwoTensor Sigma = _psie[_qp] * I2 - H.transpose() * _stress[_qp];
RealVectorValue n = _normals[_qp]; // normals of current boundary
return raw_value(_t * Sigma * n);
```

## Dynamic

### J integral

$$
J = \int_{\Gamma} \left( (\psi_e + \frac{1}{2} \rho \dot{u}^2) n_1 - t \cdot \frac{\partial u}{\partial x_1}\right) \; d\Gamma,
$$

or

$$
J = \int_{\Gamma} \left( \frac{1}{2} (\sigma_{ij} u_{i,j} + \rho V^2 u_{i,1}^2) n_1 - \sigma_{ij}n_j u_{i,1}\right) \; d\Gamma,
$$

where $\dot{u}_i=-V u_{i, 1}$

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
$K_I^0(t, l(t), 0)$: the dynamic stress intensity factor?

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

If we have $K_I=K_{Ic}$

### Derive $V$

Assume $G=G_c$ for the right hand side of (5.9):

$$
\frac{1+\nu}{E} \frac{V^2 \alpha_d}{C_s^2R(V)} \left[k(V)K_I^0(t, l(t),0)\right]^2 = G_c
$$

$K_I$ is computed from static $J$-integral

For convenience, define $A=\dfrac{1+\nu}{E C_s^2} (K_I^0)^2$.

$$
G_c \left[4(1 - V^2/C_d^2)(1 - V^2/C_s^2) - (2 - V^2/C_s^2)^2\right] = A V^2 (1 - V/C_R)^2
$$