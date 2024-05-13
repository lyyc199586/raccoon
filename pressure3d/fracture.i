[GlobalParams]
  displacements = 'disp_X disp_Y disp_Z'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/ball_h4.msh'
  []
  # parallel_type = DISTRIBUTED
  [Partitioner]
    type = LibmeshPartitioner
    partitioner = parmetis
  []
[]

[Adaptivity]
  marker = combo
  initial_marker = initial
  initial_steps = 2
  max_h_level = ${refine}
  cycles_per_step = 5
  steps = ${refine}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [initial]
      type = BoundaryMarker
      mark = REFINE
      next_to = inner
    []
    [inner_bnd]
      type = BoundaryMarker
      mark = DO_NOTHING
      next_to = inner
    []
    [combo]
      type = ComboMarker
      markers = 'damage_marker inner_bnd'
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
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [sigma_ts]
    order = CONSTANT
    family = MONOMIAL
  []
  [sigma_hs]
    order = CONSTANT
    family = MONOMIAL
  []
  [disp_X]
  []
  [disp_Y]
  []
  [disp_Z]
  []
  [ce]
    order = CONSTANT
    family = MONOMIAL
  []
  [delta]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_nu]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
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

[AuxKernels]
  [get_f_nu]
    type = ADMaterialRealAux
    property = f_nu
    variable = f_nu
  []
  [get_ce]
    type = ADMaterialRealAux
    property = ce
    variable = ce
  []
  [get_delta]
    type = ADMaterialRealAux
    property = delta
    variable = delta
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   property_name = g
  #   # expression = (1-d)^p*(1-eta)+eta
  #   expression = (1-d)^p+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  [nodeg]
    type = NoDegradation
    property_name = g
    expression = 1
    phase_field = d
  []
  [psi]
    type = ADDerivativeParsedMaterial
    property_name = psi
    expression = 'alpha*(delta*Gc/c0/l)+g*psie_active'
    coupled_variables = 'd psie_active'
    material_property_names = 'delta alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [sigma_ts]
    type = ADParsedMaterial
    property_name = sigma_ts 
    coupled_variables = 'sigma_ts'
    expression = 'sigma_ts'
  []
  [sigma_hs]
    type = ADParsedMaterial
    property_name = sigma_hs 
    coupled_variables = 'sigma_hs'
    expression = 'sigma_hs'
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
    output_properties = 'stress'
  []
  [strain]
    type = ADComputeSmallStrain
    # displacements = 'disp_X disp_Y'
  []
  [nucforce]
    type = LDLNucleationMicroForce
    phase_field = d
    degradation_function = g
    regularization_length = l
    normalization_constant = c0
    tensile_strength = sigma_ts
    hydrostatic_strength = sigma_hs
    fracture_toughness = Gc
    delta = delta
    external_driving_force_name = ce
    stress_balance_name = f_nu
    h_correction = true
    output_properties = 'ce f_nu delta'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  # petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  # petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  # automatic_scaling = true
  
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
[]

[Outputs]
  print_linear_residuals = false
[]