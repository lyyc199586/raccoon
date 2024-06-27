[Mesh]
  # [fmg]
  #   type = FileMeshGenerator
  #   file = 'pre_load_u0.0025.e'
  #   use_for_exodus_restart = true
  # []
[]

[Adaptivity]
  marker = combo_marker
  max_h_level = ${refine}
  initial_marker = initial
  initial_steps = ${refine}
  cycles_per_step = ${refine}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.01
      upper_bound = 1
    []
    # [psic_marker]
    #   type = ValueThresholdMarker
    #   variable = psie_active
    #   refine = 0.00075
    # []
    [initial]
      type = BoxMarker
      # bottom_left = '3.76 -0.26 0'
      # top_right = '4.24 0.26 0'
      bottom_left = '48.9 -1.1 0'
      top_right = '51.1 1.1 0'
      inside = REFINE
      outside = DONT_MARK
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker initial'
    []
  []
[]

[Variables]
  [d]
  []
[]

[AuxVariables]
  [bounds_dummy]
  []
  [disp_x]
    # initial_from_file_var = 'disp_x' 
    # initial_from_file_timestep = LATEST
  []
  [disp_y]
    # initial_from_file_var = 'disp_y' 
    # initial_from_file_timestep = LATEST
  []
  # [strain_zz]
  #   # initial_from_file_var = 'strain_zz'
  #   # initial_from_file_timestep = LATEST
  # []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
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
    # block = '3'
  []
  # [fixed]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = upper
  #   bound_value = 0.00001
  #   block = '0 1 2'
  # []
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

# [AuxKernels]
#   # [get_f_nu]
#   #   type = ADMaterialRealAux
#   #   property = f_nu
#   #   variable = f_nu_var
#   # [
#   # [get_psi_f_var]
#   #   type = ADMaterialRealAux
#   #   property = psi_f
#   #   variable = psi_f_var
#   # []
# []

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
    # parameter_values = '2 1 0.0 1e-6'
    parameter_values = '2 1 0.0 1e-5'
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
    type = ADComputeSmallStrain
    # type = ADComputePlaneSmallStrain
    # out_of_plane_strain = 'strain_zz'
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
    # decomposition = SPECTRAL
    decomposition = NONE
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
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  # petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  # petsc_options_iname = '-pc_type -snes_type'
  # petsc_options_value = 'asm      vinewtonrsls'
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-6

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
