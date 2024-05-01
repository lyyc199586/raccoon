[Problem]
  solve = false
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/annulus_h15.msh'
  []
[]

[AuxVariables]
  [scale]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[ICs]
  [random]
    type = RandomIC
    variable = scale
    max = 2
    min = -1
    seed = ${seed}
  []
[]

[Materials]
  [psic]
    type = ADParsedMaterial
    property_name = 'psic'
    constant_names = 'psic0'
    constant_expressions = '${psic}'
    coupled_variables = scale
    expression = 'psic0*(10 + ceil(scale))/10'
    output_properties = 'psic'
    outputs = exodus
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -pc_factor_shift_amount '
  petsc_options_value = 'lu mumps NONZERO 1e-14' # lu superlu_dist vinewtonrsls
  automatic_scaling = false
  # off_diagonals_in_auto_scaling = true
  line_search = none
  compute_scaling_once = true # true #is recommended
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-8
  nl_max_its = 20
  # l_abs_tol = 1e-9
  l_tol = 1e-5
  l_max_its = 10000
  dtmin = 1e-4

  start_time = 0
  end_time = 0.01
  num_steps = 1
[]

[Outputs]
  [exodus]
    type = Exodus
    # enable = false
  []
  file_base = patches
[]