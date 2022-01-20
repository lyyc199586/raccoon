[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 3
  ymin = 1
  ymax = 4
  nx = 100
  ny = 100
[]

[Problem]
  coord_type = RZ
[]

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
  [source_p]
    type = ADCoefMatSource
    variable = p
    prop_names = 's'
    coefficient = -1
  []
[]

[Functions]
  [s_func]
    type = ParsedFunction
    value = 'r:=sqrt(x^2+(y-1.75)^2); if(t<0.1,if(r<0.25,5e-4,0),0)'
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
    point = '0.5 1.01 0.0'
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
  end_time = 2.1
  dt = 1.5e-3
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
  []
[]