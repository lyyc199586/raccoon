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

[Distributions]
  [normal]
    type = Normal 
    mean = 1
    standard_deviation = 0.05
  []
[]

[ICs]
  [random]
    type = RandomIC
    variable = scale
    max = 2
    min = -1
    # distribution = normal
    seed = ${seed}
  []
[]

[Materials]
  # [E]
  #   type = ADParsedMaterial
  #   property_name = 'E'
  #   constant_names = 'E0'
  #   constant_expressions = '${E}'
  #   coupled_variables = scale
  #   expression = 'E0*(10 + ceil(scale))/10'
  #   output_properties = 'E'
  #   outputs = exodus
  # []
  [sigma_ts]
    type = ADParsedMaterial
    property_name = 'sigma_ts'
    constant_names = 'sigma_ts0'
    constant_expressions = '${sigma_ts}'
    coupled_variables = scale
    expression = 'sigma_ts0*(19 + ceil(scale))/20'
    # expression = 'scale*sigma_ts0'
    output_properties = 'sigma_ts'
    outputs = exodus
  []
  [sigma_hs]
    type = ADParsedMaterial
    property_name = 'sigma_hs'
    constant_names = 'sigma_hs0'
    constant_expressions = '${sigma_hs}'
    coupled_variables = scale
    expression = 'sigma_hs0*(19 + ceil(scale))/20'
    # expression = 'scale*sigma_hs0'
    output_properties = 'sigma_hs'
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