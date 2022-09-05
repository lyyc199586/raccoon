[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 50
    xmax = 2
    ymax = 1
  []
[]

[Problem]
  # coord_type = RZ
  coord_type = XYZ
[]

[Variables]
  [p]
  []
[]

[Kernels]
  [inertia_p]
    type = InertialForce
    variable = p
    block = 0
  []
  [diff_p]
    type = ADCoefMatDiffusion
    variable = 'p'
    prop_names = 'Diff'
    block = 0
  []
  # [source_p]
  #   type = ADCoefMatSource
  #   variable = p
  #   prop_names = 's'
  #   coefficient = -1
  # []
[]

# p_max = 1
[Functions]
  [s_func]
    type = ParsedFunction
    value = 'h:=(1 + tanh((t-t1)/tRT))*exp(-(t-t1)/tL)*cos(2*pi*fL*(t-t1) + pi/3);
            1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)*1000*p_max'
    vars = 'fL      t1   tRT  tL  tP  p0     d1 c1      c2     rho  p_max'
    vals = '8.33e-2 0.07 0.01 0.8 1.0 2.1e-8 9  12.2189 0.9404 1e-3 ${p_max}'
  []
[]

[Materials]
  [density] # this is actually the coef = 1/rho/cf^2
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 444.44
  []
  [diff] # this is actually the coef = 1/rho
    type = ADGenericConstantMaterial
    prop_names = 'Diff'
    prop_values = '1000'
  []
  # [source]
  #   type = ADGenericFunctionMaterial
  #   prop_names = 's'
  #   prop_values = 's_func'
  # []
[]

[BCs]
  [p_bc]
    type = FunctionDirichletBC
    variable = p
    boundary = left
    function = s_func
  []
[]

[Postprocessors]
  [p_0]
    type = PointValue
    variable = p
    point = '0.0 0.0 0.0'
  []
  [p_1]
    type = PointValue
    variable = p
    point = '2.0 0.0 0.0'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # automatic_scaling = true
  # end_time = 2.4
  end_time = 2.1
  dt = 1.5e-3
  # end_time = 1
  # dt = 1e-3
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
  [csv]
    type = CSV
    delimiter = ','
    file_base = 'acoustic'
  []
  [exodus]
    type = Exodus
    interval = 100
    file_base = fluid
  []
[]
