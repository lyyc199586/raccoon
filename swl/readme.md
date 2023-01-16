# NPL fatigue

## formulations

> Lorenzis's 2020 CMAME paper

Cumulated history variable
$$
\overline{\alpha}(x, t) = \int_0^t H(\alpha \dot{\alpha}) |\dot{\alpha}| d\tau.
$$

Faitigue degradation function (asymptotic)
$$
f(\overline{\alpha})=\begin{cases}
  1 \text{ if } \overline{\alpha} \le \alpha_T,\\
  \left(2\alpha_T\over \overline{\alpha}+\alpha_T\right)^2 \text{ if } \overline{\alpha} \ge \alpha_T.\\
\end{cases}
$$
only $G_c$ is degraded: $G_c=f(\overline{\alpha})G_c^0$

> to ensure we don't need to change $\ell$, keep $\overline{\ell}=\overline{G_c}/\overline{\psi_c}\ge 1$,
> if we only decrease $G_c$, we need to decrease $\ell$ (Roozbeh didn't do that), if we only decrease $\psi_c$, it's fine.

Choice of $\alpha$
$$
\alpha = \psi_e^+(\varepsilon, d)
$$

## 20 pulses with fatigue model

Consider $S_d=0.75$ mm, after single shot:
|$d_{max}=0.008$|$\psi_e^+=1.46\times{10}^{-2}$ MPa|
|-|-|
|![](./figures/single_d_max.png)|![](./figures/single_psie_max.png)|

Asymptotic fatigue degradation function with $\alpha_T=8.0\times{10}^{-3}$ MPa, we want fatigue happen from 2nd pusle, so $\alpha_T$ is actually small here.



