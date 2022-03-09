[Mesh]
   [./fmg]
     type = FileMeshGenerator
     file = '../mesh/2d/outer_vol_src.msh'
   [../]
[]


[Problem]
  coord_type = RZ
[]

[Variables]
  [./p]
  [../]
[]

# [AuxVariables]
#   [./vel_p]
#   [../]
#   [./accel_p]
#   [../]
#   [./accel_x]
#   [../]
#   [./accel_y]
#   [../]
# []

[Kernels]
  [./inertia_p]
    type = InertialForce
    variable = 'p'
  [../]
  [./diff_p]
    type = ADCoefMatDiffusion
    variable = 'p'
    prop_names = 'Diff'
  [../]
  [source_p]
    type = ADCoefMatSource
    variable = p
    prop_names = 's'
    coefficient = -1
  []
[]

# [DiracKernels]
#   [./monopole_source]
#     type = DiracSource
#     variable = p
#     point = '0 1.75 0'
#     dim  = 2
#     #####################################
#     fL = 8.33e-2
#     t1 = 0.07
#     tRT = 0.01
#     tL  = 0.8
#     tP  = 1.0
#     p0  = 2.1e-8
#     # p0 = 5.26e-8
#     d1  = 9
#     upcoeff = 12.2189
#     downcoeff = 0.9404
#     num_shots = 1
#     #####################################
#     rho = 1e-3
#   [../]
# []

[Functions]
  [s_func]
    type = ParsedFunction
    value = 'r:=sqrt(x^2+(y-2.0)^2);
            h:=(1 + tanh((t-t1)/tRT))*exp(-(t-t1)/tL)*cos(2*pi*fL*(t-t1) + pi/3);
            a0:=1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)*1000;
            if(r<0.1, a0, 0)'
    vars = 'fL      t1   tRT  tL  tP  p0     d1 c1      c2     rho'
    vals = '8.33e-2 0.07 0.01 0.8 1.0 2.1e-8 9  12.2189 0.9404 1e-3'
  []
[]

[Materials]
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '444.44'
  [../]
  [diff]
    type = ADGenericConstantMaterial
    prop_names = 'Diff'
    prop_values = '1000'
  [../]
  [source]
    type = ADGenericFunctionMaterial
    prop_names = 's'
    prop_values = 's_func'
  []
[]

[Postprocessors]
  [./p_1]
    type = PointValue
    variable = p
    # point = '0.5 1.01 0.0'
    point = '0 1.50 0'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # automatic_scaling = true
  end_time = 2.1
  dt = 1.5e-3
  # end_time = 1
  # dt = 1e-3
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
  [./csv]
    type = CSV
    delimiter = ','
    file_base = 'pressure_hist'
  [../]
  [./exodus]
    type = Exodus
    interval = 100
    file_base = fluid
  [../]
[]
