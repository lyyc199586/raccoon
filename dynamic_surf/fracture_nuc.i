[Mesh]
[]

# [Mesh]
#   [gen]
#     type = GeneratedMeshGenerator
#     dim = 2
#     nx = ${nx}
#     ny = ${ny}
#     xmax = ${length}
#     ymin = ${fparse -1*a}
#     ymax = ${a}
#   []
# []

# [Adaptivity]
#   initial_marker = initial_tip
#   initial_steps = ${refine}
#   marker = damage_marker
#   max_h_level = ${refine}
#   [Markers]
#     [damage_marker]
#       type = ValueThresholdMarker
#       variable = d
#       refine = 0.0001
#     []
#     [initial_tip]
#       type = BoxMarker
#       bottom_left = '0 -${fparse 2*l} 0'
#       top_right = '${fparse a + 2*l} ${fparse 2*l} 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#   []
# []

[Variables]
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=${a},1,0)'
    []
  []
[]

[AuxVariables]
  [bounds_dummy]
  []
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
  []
  [psie_active]
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
    block = '0 1'
  []
  # [conditional]
  #   type = ConditionalBoundsAux
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   fixed_bound_value = 0
  #   threshold_value = 0.95
  #   block = '0 1'
  # []
  [upper]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
    block = '1'
  []
  [fixed]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 0.0001
    block = '0'
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
    coefficient = 1.0
  []
[]


[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l sigma_ts sigma_hs'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${sigma_ts} ${sigma_hs}'
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
    parameter_values = '2 0'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [crack_surface_density] # calc gamma
    type = CrackSurfaceDensity
    phase_field = d
  []
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
  [strain]
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
    decomposition = SPECTRAL
  []
  [nucleation_micro_force]
    type = LDLNucleationMicroForce
    phase_field = d
    degradation_function = g
    regularization_length = l
    normalization_constant = c0
    fracture_toughness = Gc
    tensile_strength = sigma_ts
    hydrostatic_strength = sigma_hs
    delta = delta
    h_correction = true
    external_driving_force_name = ce
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
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
[]

[Outputs]
  #[exodus]
  #  type = Exodus
  #[]
  # [csv]
  #   type = CSV
  #   file_base = fracture_energy
  # []
  print_linear_residuals = false
[]
