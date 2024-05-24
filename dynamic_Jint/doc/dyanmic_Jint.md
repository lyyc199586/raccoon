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

## J integral

Energy release rate: loss of total potential energy per unit crack growth area (length) $s$

$$
G=-\frac{\partial\Pi}{\partial s},
$$

where the total potential energy is

$$
\Pi = W - \int_{\partial\Omega} t\cdot u \;dS - \int_{\Omega} b\cdot u \;dV,
$$

$W$ is total strain energy.

### Quasi-static

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

### Dynamic

$$
J = \int_{\Gamma} \left( (\psi_e + \frac{1}{2} \rho \dot{u}^2) n_1 - t \cdot \frac{\partial u}{\partial x_1}\right) \; d\Gamma,
$$

or

$$
J = \int_{\Gamma} \left( \frac{1}{2} (\sigma_{ij} u_{i,j} + \rho V^2 u_{i,1}^2) n_1 - \sigma_{ij}n_j u_{i,1}\right) \; d\Gamma,
$$

## Discrete crack

Use dynamic J integral on the discrete crack, using material properties and geometry from the dynamic branching problem,
compare to analytical G:

![](../post/DJint_compare.png)

