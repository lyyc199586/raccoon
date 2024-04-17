[Mesh]
  # [gen] #h_c = 1, h_r = 0.25
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = 100
  #   ny = 40
  #   xmin = 0
  #   xmax = 100
  #   ymin = -20
  #   ymax = 20
  # []
  # [sub_upper]
  #   type = ParsedSubdomainMeshGenerator
  #   input = gen
  #   combinatorial_geometry = 'x < 50 & y > 0'
  #   block_id = 1
  # []
  # [sub_lower]
  #   type = ParsedSubdomainMeshGenerator
  #   input = sub_upper
  #   combinatorial_geometry = 'x < 50 & y < 0'
  #   block_id = 2
  # []
  # [split]
  #   input = sub_lower
  #   type = BreakMeshByBlockGenerator
  #   block_pairs = '1 2'
  #   split_interface = true
  # []
  # second_order = true
[]

# [Adaptivity]
#   initial_marker = initial
#   initial_steps = ${refine}
#   [Markers]
#     [initial]
#       type = BoxMarker
#       bottom_left = '50 -20 0'
#       top_right = '100 20 0'
#       inside = REFINE
#       outside = DO_NOTHING
#     []
#   []
# []

[Adaptivity]
  marker = damage_marker
  max_h_level = ${refine}
  cycles_per_step = 2
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [psic_marker]
      type = ValueThresholdMarker
      variable = psie_active
      refine = 0.00075
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker psic_marker'
    []
  []
[]

[Variables]
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=0&x<=50,1,0)'
    # []
  []
[]

[AuxVariables]
  [bounds_dummy]
    # initial_from_file_var = 'bounds_dummy' 
    # initial_from_file_timestep = LATEST
  []
  [disp_x]
    # initial_from_file_var = 'disp_x' 
    # initial_from_file_timestep = LATEST
    # order = SECOND
  []
  [disp_y]
    # initial_from_file_var = 'disp_y' 
    # initial_from_file_timestep = LATEST
    # order = SECOND
  []
  [strain_zz]
    #   initial_from_file_var = 'strain_zz' 
    #   initial_from_file_timestep = LATEST
  []
  [psie_active]
    # initial_from_file_var = 'psie_active' 
    # initial_from_file_timestep = LATEST
    order = CONSTANT
    family = MONOMIAL
  []
  # [f_nu_var]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  [psi_f_var]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  [irreversibility]
    type = VariableOldValueBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = lower
  []
  # [conditional]
  #   type = ConditionalBoundsAux
  #   variable = 'bounds_dummy'
  #   bounded_variable = 'd'
  #   fixed_bound_value = 0
  #   threshold_value = 0.95
  # []
  [upper]
    type = ConstantBounds
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
  # [nuc_force]
  #   type = ADCoefMatSource
  #   variable = d
  #   prop_names = 'ce'
  # []
[]

[AuxKernels]
  # [get_f_nu]
  #   type = ADMaterialRealAux
  #   property = f_nu
  #   variable = f_nu_var
  # [
  [get_psi_f_var]
    type = ADMaterialRealAux
    property = psi_f
    variable = psi_f_var
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${psic}'
  []
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0.0 1e-6'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  [psi]
    type = ADDerivativeParsedMaterial
    property_name = psi
    expression = 'g*psie_active+(Gc/c0/l)*alpha'
    coupled_variables = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [psi_f]
    type = ADParsedMaterial
    property_name = psi_f
    expression = 'Gc*gamma'
    coupled_variables = 'd'
    material_property_names = 'gamma(d) Gc'
  []
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  # [kumar_material] #2020
  #   type = KLBFNucleationMicroForce
  #   # phase_field = d
  #   stress_name = stress
  #   normalization_constant = c0
  #   tensile_strength = sigma_ts
  #   compressive_strength = sigma_cs
  #   delta = delta
  #   external_driving_force_name = ce
  #   stress_balance_name = f_nu
  # []
  # [kumar_material] #2022
  #   type = KLRNucleationMicroForce
  #   phase_field = d
  #   stress_name = stress
  #   normalization_constant = c0
  #   tensile_strength = sigma_ts
  #   compressive_strength = sigma_cs
  #   delta = delta
  #   external_driving_force_name = ce
  #   stress_balance_name = f_nu
  # []
  # [strain]
  #   type = ADComputePlaneSmallStrain
  #   # out_of_plane_strain = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  # []
  [strain]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
    # outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
  []
[]

[Postprocessors]
  [Psi_f]
    type = ADElementIntegralMaterialProperty
    mat_prop = psi_f
    execute_on = 'initial timestep_end'
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
  # start_time = 80e-6
  # end_time = 120e-6
[]

# [Outputs]
#   [exodus]
#     type = Exodus
#     interval = 1
#   []
#   print_linear_residuals = false
#   file_base = './outputs/fracture_ce2021_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}_dt5e-7_ctd'
#   interval = 1
#   [./csv]
#     type = CSV 
#   [../]
# []
