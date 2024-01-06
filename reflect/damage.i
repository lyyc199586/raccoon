[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 10
    # nx = 400
    # ny = 25
    xmin = 0
    xmax = 2
    ymin = 0
    ymax = 0.2
  []
  [add_crack]
    type = ParsedGenerateSideset
    input = gmg
    combinatorial_geometry = 'abs(x-1.01)<0.01'
    new_sideset_name = 'crack'
  []
[]

[Variables]
  [d]
    [InitialCondition]
      # type = ConstantIC
      # boundary = crack
      # value = 1
      type = BrittleDamageIC
      d0 = 1
      x1 = 1
      x2 = 1
      y1 = 0
      y2 = 0.2
      z1 = 0
      z2 = 0
      l = ${l}
      # bandwidth_multiplier = 2
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
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  # [irr]
  #   type = VariableOldValueBoundsAux
  #   variable = 'bounds_dummy'
  #   bounded_variable = 'd'
  #   bound_type = lower
  # []
  # [irr2]
  #   type = VariableOldValueBoundsAux
  #   variable = 'bounds_dummy'
  #   bounded_variable = 'd'
  #   bound_type = upper
  # []
  [conditional]
    type = ConditionalBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    fixed_bound_value = 0
    # threshold_value = 0.95
    threshold_value = 0.01
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
  [nuc_force]
    type = ADCoefMatSource
    variable = d
    prop_names = 'ce'
  []
[]

[ICs]
  [d_1]
    type = ConstantIC
    variable = d
    value = 1
    boundary = crack
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l sigma_ts sigma_cs delta'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${sigma_ts} ${sigma_cs} ${delta}'
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
    # function = (1-d)^p*(1-eta)+eta
    function = (1-d)^p+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
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
    expression = '(Gc/c0/l)*alpha'
    coupled_variables = 'd'
    material_property_names = 'alpha(d) Gc c0 l'
  []
  [kumar_material] #2022
    type = KLRNucleationMicroForce
    phase_field = d
    stress_name = stress
    normalization_constant = c0
    tensile_strength = sigma_ts
    compressive_strength = sigma_cs
    delta = delta
    external_driving_force_name = ce
    stress_balance_name = f_nu
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
  #   # output_properties = 'ce f_nu'
  #   # outputs = exodus
  # []
  [strain]
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
    output_properties = 'stress'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  # petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_type -snes_linesearch_damping'
  petsc_options_value = 'hypre boomeramg      vinewtonrsls 0.5'
  line_search = basic
  automatic_scaling = true
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
[]
