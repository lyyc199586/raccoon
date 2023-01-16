[Mesh]
  type = GeneratedMesh
  dim = 3
  xmin = 0
  xmax = 2
  ymin = -1
  ymax = 1
  zmin = -1
  zmax = 1
  nx = 30
  ny = 30
  nz = 30
[]
# h = 0.02

# [Problem]
#   coord_type = RZ
# []

[Variables]
  [p]
  []
[]

[Kernels]
  [inertia_p]
    type = InertialForce
    variable = p
  []
  [diff_p]
    type = ADCoefMatDiffusion
    variable = p
    prop_names = 'D'
  []
  # [source_p]
  #   type = ADCoefMatSource
  #   variable = p
  #   prop_names = 's'
  #   coefficient = -1
  # []
[]

[DiracKernels]
  [point_source]
    type = FunctionDiracSource
    variable = p
    function = s_func
    point = '0.0 0.0 0.0'
  []
[]

# [Functions]
#   [./switch_off]
#     type = ParsedFunction
#     value = 'if(t < 0.1, 5e-4, 0)'
#   [../]
# []

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
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '444.44'
  []
  [diff]
    type = ADGenericConstantMaterial
    prop_names = 'D'
    prop_values = '1000'
  []
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
    point = '0.5 0.0 0.0'
    # point = '0 1.75 0'
  [../]
  [./p_2]
    type = PointValue
    variable = p
    point = '0.6 0.0 0.0'
    # point = '0 1.75 0'
  [../]
  [./p_3]
    type = PointValue
    variable = p
    point = '0.7 0.0 0.0'
    # point = '0 1.75 0'
  [../]
  [./p_4]
    type = PointValue
    variable = p
    point = '0.8 0.0 0.0'
    # point = '0 1.75 0'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  end_time = 1.5
  dt = 1e-3
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
[./csv]
    type = CSV
    delimiter = ','
    file_base = 'p_3d'
  [../]
  [./exodus]
    type = Exodus
    interval = 100
    file_base = test_3d
  []
[]