[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/scb_2d_cw1_half.msh'
  []
[]

[Problem]
  coord_type = XYZ
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
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
  [strain_zz]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  [conditional]
    type = ConditionalBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    fixed_bound_value = 0
    threshold_value = 0.95
  []
  [upper]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
    # bound_value = 0
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

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 0'
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
    function = 'g*psie_active+(Gc/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [kumar_material]
    type = NucleationMicroForce
    normalization_constant = c0
    tensile_strength = '${sigma_ts}'
    compressive_strength = '${sigma_cs}'
    delta = '${delta}'
    external_driving_force_name = ce
    f_sigma_name = f_sigma
    output_properties = 'ce f_sigma'
    outputs = exodus
  []
  # [strain]
  #   type = ADComputeSmallStrain
  # []
  [strain]
    # type = ADComputeSmallStrain
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
    decomposition = NONE
    # output_properties = 'psie'
    # outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
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
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
   type = Exodus
   interval = 1
  []
  # file_base = './scb_${E}_ts${sigma_ts}_cs${sigma_cs}_nuc_force'
  file_base = './scb_cw1_nuc_force'
  print_linear_residuals = false
[]
