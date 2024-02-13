nu = 0
E_mid = '${fparse E/2}'
K_mid = '${fparse E_mid/3/(1-2*nu)}'
G_mid = '${fparse E_mid/2/(1+nu)}'
Lambda_mid = '${fparse E_mid*nu/(1+nu)/(1-2*nu)}'

[Mesh]
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
  # [disp_y]
  # []
  # [disp_z]
  # []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  [conditional]
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
  [nuc_force]
    type = ADCoefMatSource
    variable = d
    prop_names = 'ce'
    coefficient = -1.0
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Gc l sigma_ts sigma_hs'
    prop_values = '${Gc} ${l} ${sigma_ts} ${sigma_hs}'
  []
  [K]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'K'
    subdomain_to_prop_value = '0 ${K} 1 ${K_mid}'
    output_properties = 'K'
    outputs = exodus
  []
  [G]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'G'
    subdomain_to_prop_value = '0 ${G} 1 ${G_mid}'
  []
  [lambda]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'lambda'
    subdomain_to_prop_value = '0 ${Lambda} 1 ${Lambda_mid}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(Gc*delta/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'delta alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [nucleation_micro_force]
    type = LDLNucleationMicroForce
    regularization_length = l
    normalization_constant = c0
    fracture_toughness = Gc
    tensile_strength = sigma_ts
    hydrostatic_strength = sigma_hs
    delta = delta
    # h_correction = true
    external_driving_force_name = ce
    output_properties = 'ce delta'
    outputs = exodus
  []
  [strain]
    type = ADComputeSmallStrain
    # displacements = 'disp_x disp_y disp_z'
    displacements = 'disp_x'
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
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 500
[]

[Outputs]
  [exodus]
    type = Exodus
    # file_base = './out/1d_bar_fracture_with-h-correct_l${l}'
    file_base = './out/1d_bar_fracture_l${l}'
  []
  print_linear_residuals = false
[]