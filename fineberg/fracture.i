sigma_hs = '${fparse 2/3*sigma_ts*sigma_cs/(sigma_cs - sigma_ts)}'
Lambda = '${fparse K - 2/3*G}'

[Mesh]
[]

# [Adaptivity]
#   marker = combo_marker
#   max_h_level = ${refine}
#   # initial_marker = initial
#   # initial_steps = ${refine}
#   cycles_per_step = ${refine}
#   [Markers]
#     [damage_marker]
#       type = ValueRangeMarker
#       variable = d
#       lower_bound = 0.01
#       upper_bound = 1
#     []
#     [psie_marker]
#       type = ValueThresholdMarker
#       variable = psie_active
#       refine = '${fparse 0.9*psic}'
#     []
#     # [initial]
#     #   type = BoxMarker
#     #   bottom_left = '9.9 -1.1 0'
#     #   top_right = '11.1 1.1 0'
#     #   inside = REFINE
#     #   outside = DONT_MARK
#     # []
#     [combo_marker]
#       type = ComboMarker
#       markers = 'damage_marker'
#     []
#   []
# []

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
  [strain_zz]
    # initial_from_file_var = 'strain_zz'
    # initial_from_file_timestep = LATEST
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  # [psi_f_var]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
[]

[Bounds]
  # [irreversibility]
  #   type = VariableOldValueBounds
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
  [upper]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
    block = 'crack_region'
  []
  [fixed]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 0.00001
    block = 'body'
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
    prop_names = 'K G Gc l psic sigma_ts sigma_hs lambda'
    prop_values = '${K} ${G} ${Gc} ${l} ${psic} ${sigma_ts} ${sigma_hs} ${Lambda}'
  []
  # [degradation]
  #   type = RationalDegradationFunction
  #   property_name = g
  #   phase_field = d
  #   material_property_names = 'Gc psic xi c0 l'
  #   parameter_names = 'p a2 a3 eta'
  #   parameter_values = '2 1 0.0 1e-6'
  # []
  [degradation]
    type = PowerDegradationFunction
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [cnh]
    type = CNHIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
  []
  [stress]
    type = ComputeLargeDeformationStress
    elasticity_model = cnh
  []
  [defgrad]
    type = ComputePlaneDeformationGradient
    out_of_plane_strain = strain_zz
    displacements = 'disp_x disp_y'
  []
  # [psi]
  #   type = ADDerivativeParsedMaterial
  #   property_name = psi
  #   expression = 'g*psie_active+(Gc/c0/l)*alpha'
  #   coupled_variables = 'd psie_active'
  #   material_property_names = 'alpha(d) g(d) Gc c0 l'
  #   derivative_order = 1
  # []
  [psi]
    type = ADDerivativeParsedMaterial
    property_name = psi
    expression = 'g*psie_active+(delta*Gc/c0/l)*alpha'
    coupled_variables = 'd psie_active'
    material_property_names = 'delta alpha(d) g(d) Gc c0 l'
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
  [ldl]
    type = LDLNucleationMicroForce
    phase_field = d
    degradation_function = g
    regularization_length = l
    normalization_constant = c0
    tensile_strength = sigma_ts
    hydrostatic_strength = sigma_hs
    fracture_toughness = Gc
    delta = delta
    h_correction = true
    external_driving_force_name = ce
    stress_balance_name = f_nu
    output_properties = 'ce f_nu delta'
    outputs = exodus
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
  # petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  # petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  # petsc_options_iname = '-pc_type -snes_type'
  # petsc_options_value = 'asm      vinewtonrsls'
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # nl_rel_tol = 1e-4
  # nl_abs_tol = 1e-6

  # restart
  # start_time = 80e-6
  # end_time = 120e-6
[]

[Outputs]
  [exodus]
    type = Exodus
    # min_simulation_time_interval = 0.25
  []
[]
