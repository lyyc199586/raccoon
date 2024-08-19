# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

u0 = 0.0025
t0 = 0.01
h = 1
ref = 3

nx = '${fparse int(100/h)}'
ny = '${fparse int(40/h)}'

filebase = pre_u0${u0}