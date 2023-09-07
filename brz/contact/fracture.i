[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/disc_r25_h1.msh'
  []
  [left_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x < -${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'left_arc'
    input = fmg
  []
  [right_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x > ${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'right_arc'
    input = left_arc
  []
[]

[Adaptivity]
  initial_marker = initial_marker
  initial_steps = ${refine}
  # marker = damage_marker
  max_h_level = ${refine}
  [Markers]
    # [damage_marker]
    #   type = ValueRangeMarker
    #   variable = d
    #   lower_bound = 0.0001
    #   upper_bound = 1
    # []
    # [strength_marker]
    #   type = ValueRangeMarker
    #   variable = f_nu_var
    #   lower_bound = -1e-2
    #   upper_bound = 1e-2
    # []
    # [combo_marker]
    #   type = ComboMarker
    #   markers = 'damage_marker combo_marker'
    # []
    [initial_marker]
      type = BoxMarker
      bottom_left = '-${r} -8 0'
      top_right = '${r} 8 0'
      outside = DO_NOTHING
      inside = REFINE
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
  [strain_zz]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_nu_var]
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
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
    # bound_value = 0 # no damage
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
    variable = f_nu_var
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
    # parameter_values = '2 0'
  []
  # [nodegradation] # elastic test
  #   type = NoDegradation
  #   f_name = g 
  #   function = 1
  #   phase_field = d
  # []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(Gc/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [kumar_material]
    type = KLRNucleationMicroForce
    phase_field = d
    stress_name = stress
    normalization_constant = c0
    tensile_strength = sigma_ts
    compressive_strength = sigma_cs
    delta = delta
    external_driving_force_name = ce
    stress_balance_name = f_nu
    # output_properties = 'ce f_nu'
    # outputs = exodus
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
    decomposition = NONE
    # decomposition = VOLDEV
    # output_properties = 'psie'
    # outputs = exodus
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
  # petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  # petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  automatic_scaling = true

  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8

  # restart
  # start_time = 80e-6
  # end_time = 120e-6
[]
