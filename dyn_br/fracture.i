sigma_hs = '${fparse 2/3*sigma_ts*sigma_cs/(sigma_cs - sigma_ts)}'

[Mesh]
[]

[Adaptivity]
  marker = combo_marker
  max_h_level = ${refine}
  cycles_per_step = ${refine}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [strength_marker]
      type = ValueRangeMarker
      variable = f_nu_var
      lower_bound = -1e-4
      upper_bound = 1e-4
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker strength_marker'
    []
  []
[]

[Variables]
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=0&x<=50,1,0)'
    # []
  []
[]

[AuxVariables]
  [bounds_dummy]
    # initial_from_file_var = 'bounds_dummy' 
    # initial_from_file_timestep = LATEST
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
    #   initial_from_file_var = 'strain_zz' 
    #   initial_from_file_timestep = LATEST
  []
  [ce_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [delta_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [psie_active]
    # initial_from_file_var = 'psie_active' 
    # initial_from_file_timestep = LATEST
    order = CONSTANT
    family = MONOMIAL
  []
  [f_nu_var]
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
  [conditional]
    type = ConditionalBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    fixed_bound_value = 0
    threshold_value = 0.95
  []
  # [upper]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = upper
  #   bound_value = 1
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
  [nuc_force]
    type = ADCoefMatSource
    variable = d
    prop_names = 'ce'
    coefficient = -1
  []
[]

[AuxKernels]
  [get_f_nu]
    type = ADMaterialRealAux
    property = f_nu
    variable = f_nu_var
  []
  [get_ce]
    type = ADMaterialRealAux
    property = ce
    variable = ce_var
  []
  [get_delta]
    type = ADMaterialRealAux
    property = delta
    variable = delta_var
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l sigma_ts sigma_hs'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${sigma_ts} ${sigma_hs}'
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
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(Gc*delta/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'delta alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [psi_f]
    type = ADParsedMaterial
    property_name = psi_f
    expression = 'delta*Gc*gamma'
    coupled_variables = 'd'
    material_property_names = 'delta gamma(d) Gc'
  []
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [psi_f_ce]
    type = ADParsedMaterial
    property_name = psi_f_ce
    expression = 'ce*(1-d)/3'
    coupled_variables = 'd'
    material_property_names = 'ce'
  []
  [nucforce]
    type = LDLNucleationMicroForce
    regularization_length = l
    normalization_constant = c0
    tensile_strength = sigma_ts
    hydrostatic_strength = sigma_hs
    fracture_toughness = Gc
    delta = delta
    external_driving_force_name = ce
    stress_balance_name = f_nu
    h_correction = true
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
  [strain]
    type = ADComputePlaneSmallStrain
    # type = ADComputeSmallStrain
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
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    # output_properties = 'stress'
  []
[]

[Postprocessors]
  [Psi_f]
    type = ADElementIntegralMaterialProperty
    mat_prop = psi_f
  []
  [Psi_f_ce]
    type = ADElementIntegralMaterialProperty
    mat_prop = psi_f_ce
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  # petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  # petsc_options_iname = '-pc_type -snes_type'
  # petsc_options_value = 'asm      vinewtonrsls'
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

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
