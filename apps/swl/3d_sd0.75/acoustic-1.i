[Mesh]
   [./fmg]
     type = FileMeshGenerator
     file = '../mesh/3d/outer.msh'
   [../]
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
#   [./accel_z]
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
[]

# [DiracKernels]
#   [./monopole_source]
#     type = DiracSource
#      variable = p
#      point = '0.0 1.75 0.0'
#      dim  = 3
#      #####################################
#      fL = 8.33e-2
#      t1 = 0.07
#      tRT = 0.01
#      tL  = 0.8
#      tP  = 1.0
#      p0  = 2.1e-8
#      d1  = 9
#      upcoeff = 12.2189
#      downcoeff = 0.9404
#      num_shots = 1
#      #####################################
#      rho = 1e-3
#   [../]
# []

[DiracKernels]
  [point_source]
    type = FunctionDiracSource
    variable = p
    function = s_func
    point = '0.00 1.75 0.0'
  []
[]

[Functions]
  [s_func]
    type = ParsedFunction
    value = 'h:=(1 + tanh((t-t1)/tRT))*exp(-(t-t1)/tL)*cos(2*pi*fL*(t-t1) + pi/3);
            1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)'
    vars = 'fL      t1   tRT  tL  tP  p0 d1 c1      c2     rho'
    vals = '8.33e-2 0.07 0.01 0.8 1.0 1  9  12.2189 0.9404 1e-3'
  []
[]

[Materials]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '444.44'
  [../]
  [./diff]
    type = ADGenericConstantMaterial
    prop_names = 'Diff'
    prop_values = '1000'
  [../]
[]

[Postprocessors]
  [./p_1]
    type = PointValue
    variable = p
    point = '0.0 1.01 0.0'
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
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
  [./csv]
    type = CSV
    delimiter = ' '
    file_base = 'pressure_hist'
  [../]
  [./exodus]
    type = Exodus
    interval = 100
    file_base = fluid
  [../]
[]

