[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/quarter_cylinder_r20_t30_h1_transfinite.msh'
    # file = './out/frag_3d_coh_l1_v0-1e4/frag_3d_coh_l1_v0-1e4_cp/0175-mesh.cpr'
  []
  [load]
    type = ParsedGenerateSideset
    input = fmg
    combinatorial_geometry = 'abs(sqrt(x^2 + y^2)) < 5.1 & z > 29.9'
    new_sideset_name = load
  []
  [front]
    type = ParsedGenerateSideset
    input = load
    combinatorial_geometry = 'y < 0.1'
    new_sideset_name = front
  []
  [left]
    type = ParsedGenerateSideset
    input = front
    combinatorial_geometry = 'x < 0.1'
    new_sideset_name = left
  []
  coord_type = XYZ
[]

[Adaptivity]
  # initial_marker = initial
  # initial_steps = ${refine}
  marker = combo_marker
  max_h_level = ${refine}
  cycles_per_step = 3
  # start_time = 2e-7
  [Markers]
    [initial]
      type = BoxMarker
      bottom_left = '-0.1 -0.1 28.9'
      top_right = '5.1 5.1 30.1'
      inside = REFINE
      outside = DO_NOTHING
    []
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [psic_marker]
      type = ValueThresholdMarker
      variable = psie_active
      refine = ${fparse psic*0.75}
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker'
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
  []
  [disp_y]
  []
  [disp_z]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  [irreversibility]
    type = VariableOldValueBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    bound_type = lower
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

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${psic}'
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 -0.5 0.0 1e-6'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
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
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [strain]
    type = ADComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
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
    # output_properties = 'stress'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  # petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_type'
  petsc_options_value = 'hypre    boomeramg      vinewtonrsls'
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  # start_time = 17.4e-6
  # end_time = 50e-6
[]