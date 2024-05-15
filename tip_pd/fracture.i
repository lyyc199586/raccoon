[Mesh]
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
      lower_bound = 0.0001
      upper_bound = 1
    []
    [psic_marker]
      type = ValueThresholdMarker
      variable = psie_active
      refine = 0.00075
    []
    [initial]
      type = BoxMarker
      bottom_left = '47.9 -2.1 0'
      top_right = '52.1 2.1 0'
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
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=49.5&x<=50.5,1,0)'
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
  # [strain_zz]
  # []
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
  []
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
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0.0 1e-6'
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
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [strain]
    # type = ADComputePlaneSmallStrain
    type = ADComputeSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    # output_properties = 'stress'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
[]