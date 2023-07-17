[Problem]
  kernel_coverage_check = false
  material_coverage_check = false
[]

[Mesh]
  [gen]
    type = FileMeshGenerator
    file = '../mesh/half.msh'
  []
  [toplayer]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'y > 74'
    block_id = 1
    block_name = top_layer
  []
  [noncrack]
    type = BoundingBoxNodeSetGenerator
    input = toplayer
    new_boundary = noncrack
    bottom_left = '26.9 0 0'
    top_right = '100.1 0 0'
  []
  construct_side_list_from_node_list = true
[]

[Adaptivity]
  initial_marker = initial_tip
  initial_steps = ${refine}
  marker = damage_marker
  max_h_level = ${refine}
  [Markers]
    [damage_marker]
      type = ValueThresholdMarker
      variable = d
      refine = 0.001
    []
    [initial_tip]
      type = BoxMarker
      bottom_left = '26 0 0'
      top_right = '28 1 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Variables]
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=19&x<=27,1,0)'
    # []
    block = 0
  []
[]

[AuxVariables]
  [bounds_dummy]
    # initial_from_file_var = 'bounds_dummy' 
    # initial_from_file_timestep = LATEST
    block = 0
  []
  [disp_x]
    # initial_from_file_var = 'disp_x' 
    # initial_from_file_timestep = LATEST
    block = 0
  []
  [disp_y]
    # initial_from_file_var = 'disp_y' 
    # initial_from_file_timestep = LATEST
    block = 0
  []
  [strain_zz]
    # initial_from_file_var = 'strain_zz' 
    # initial_from_file_timestep = LATEST
    block = 0
  []
  [psie_active]
    # initial_from_file_var = 'psie_active' 
    # initial_from_file_timestep = LATEST
    order = CONSTANT
    family = MONOMIAL
    block = 0
  []
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
    block = 0
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
    block = 0
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
    block = 0
  []
[]

[Kernels]
  [diff]
    type = ADPFFDiffusion
    variable = d
    fracture_toughness = Gc
    regularization_length = l
    normalization_constant = c0
    block = 0
  []
  [source]
    type = ADPFFSource
    variable = d
    free_energy = psi
    block = 0
  []
  [nuc_force]
    type = ADCoefMatSource
    variable = d
    prop_names = 'ce'
    block = 0
  []
[]

[AuxKernels]
  [get_f_nu]
    type = ADMaterialRealAux
    property = f_nu
    variable = f_nu_var
    block = 0
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
    block = 0
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
    block = 0
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
    block = 0
  []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(Gc/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
    block = 0
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
    # outputs = exodus
    block = 0
  []
  [strain]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    block = 0
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
    block = 0
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    block = 0
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

  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8
  # nl_abs_tol = 1e-6

  # restart
  # start_time = 80e-6
  # end_time = 120e-6
[]

# [Outputs]
#   print_linear_residuals = false
# []

# [Outputs]
#   [exodus]
#     type = Exodus
#     interval = 10
#   []
#   print_linear_residuals = false
#   file_base = './out/fix_top/pd_p${p}_gc${Gc}_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
#   interval = 1
#   # [./csv]
#   #   type = CSV 
#   # [../]
# []