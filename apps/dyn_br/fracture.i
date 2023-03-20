[Mesh]
  # [gen]
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = 400
  #   ny = 160
  #   # nx = 800
  #   # ny = 320
  #   xmin = 0
  #   xmax = 100
  #   ymin = -20
  #   ymax = 20
  # []
  [gen1]
    use_for_exodus_restart = true
    type = FileMeshGenerator
    file = './outputs/fracture_ts3.08_cs9.24_l2_delta4_dt5e-7.e'
  []
[]

[Variables]
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=50,1,0)'
    []
  []
[]

[AuxVariables]
  [bounds_dummy]
    initial_from_file_var = 'bounds_dummy' 
    initial_from_file_timestep = LATEST
  []
  [disp_x]
    initial_from_file_var = 'disp_x' 
    initial_from_file_timestep = LATEST
  []
  [disp_y]
    initial_from_file_var = 'disp_y' 
    initial_from_file_timestep = LATEST
  []
  [strain_zz]
    initial_from_file_var = 'strain_zz' 
    initial_from_file_timestep = LATEST
  []
  [psie_active]
    initial_from_file_var = 'psie_active' 
    initial_from_file_timestep = LATEST
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  # [irreversibility]
  #   type = VariableOldValueBoundsAux
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = lower
  # []
  [conditional]
    type = ConditionalBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    fixed_bound_value = 0
    threshold_value = 0.95
  []
  # [history]
  #   type = HistoryFieldBoundsAux
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   history_variable = d_max
  #   fixed_bound_value = 0
  #   search_radius = 2
  #   threshold_ratio = 0.95
  # []
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
  [nuc_force]
    type = ADCoefMatSource
    variable = d
    prop_names = 'ce'
  []
[]

# [AuxKernels]
#   [hist]
#     type = HistoryField
#     variable = d_max 
#     source_variable = d
#     # execute_on = timestep_begin
#     execute_on = linear
#   []
# []

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(Gc/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [kumar_material]
    type = LinearNucleationMicroForce2021
    phase_field = d
    if_stress_intact = false
    stress_name = stress
    normalization_constant = c0
    tensile_strength = '${sigma_ts}'
    compressive_strength = '${sigma_cs}'
    delta = '${delta}'
    external_driving_force_name = ce
    stress_balance_name = f_nu
    output_properties = 'ce f_nu'
    outputs = exodus
  []
  [strain]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # decomposition = VOLDEV
    # output_properties = 'psie'
    # outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
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

  # restart
  start_time = 80e-6
  end_time = 120e-6
[]

# [Outputs]
#   print_linear_residuals = false
# []

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
  []
  print_linear_residuals = false
  file_base = './outputs/fracture_ce2021_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}_dt5e-7_ctd'
  interval = 1
  [./csv]
    type = CSV 
  [../]
[]