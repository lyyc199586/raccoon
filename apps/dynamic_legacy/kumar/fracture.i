[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 400
    ny = 160
    # nx = 800
    # ny = 320
    xmin = 0
    xmax = 100
    ymin = -20
    ymax = 20
  []
  # [./fmg]
  #   type = FileMeshGenerator
  #   use_for_exodus_restart = true
  #   file = 'kumar_cond_3_l1.5_delta3.9_dt1e-7}.e'
  # [../]
[]

[Variables]
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=50,1,0)'
    []
    # initial_from_file_var = 'd' # for restart
    # initial_from_file_timestep = 34 # for restart
  []
[]

[AuxVariables]
  [bounds_dummy]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
    # initial_from_file_var = 'psie_active' # for restart
    # initial_from_file_timestep = 34 # for restart
  []
  [ce] # add ce
    order = CONSTANT
    family = MONOMIAL
    # initial_from_file_var = 'ce' # for restart
    # initial_from_file_timestep = 34 # for restart
  []
  [d_max]
    # initial_from_file_var = 'd_max' # for restart
    # initial_from_file_timestep = 34 # for restart
  []
[]

[Bounds]
  # [irreversibility]
  #   type = VariableOldValueBoundsAux
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = lower
  # []
  # [conditional]
  #   type = ConditionalBoundsAux
  #   variable = 'bounds_dummy'
  #   bounded_variable = 'd'
  #   fixed_bound_value = 0
  #   threshold_value = 0.95
  # []
  [history]
    type = HistoryFieldBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    history_variable = d_max
    fixed_bound_value = 0
    search_radius = 2
    threshold_ratio = 0.95
  []
  [upper]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
  []
[]

[Kernels]
  [diff]
    type = ADPFFDiffusion
    variable = d
    fracture_toughness = Gc
    regularization_length = l
    normalization_constant = c0
  []
  [source]
    type = ADPFFSource
    variable = d
    free_energy = psi
  []
[]

[AuxKernels]
  [hist]
    type = HistoryField
    variable = d_max 
    source_variable = d
    # execute_on = timestep_begin
    execute_on = linear
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G Lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  # [degradation]
  #   type = RationalDegradationFunction
  #   f_name = g
  #   function = (1-d)^p/((1-d)^p+(Gc/psic*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta
  #   phase_field = d
  #   material_property_names = 'Gc psic xi c0 l '
  #   parameter_names = 'p a2 a3 eta '
  #   parameter_values = '2 -0.5 0 1e-6'
  # []
  # [psi]
  #   type = ADDerivativeParsedMaterial
  #   f_name = psi
  #   function = 'alpha*Gc/c0/l+g*psie_active'
  #   args = 'd psie_active'
  #   material_property_names = 'alpha(d) g(d) Gc c0 l'
  #   derivative_order = 1
  # []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 0'
  []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(ce+Gc/c0/l)*alpha'
    args = 'd psie_active ce'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  # petsc_options_iname = '-pc_type -snes_type'
  # petsc_options_value = 'asm      vinewtonrsls'
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
[]

[Outputs]
  print_linear_residuals = false
[]
