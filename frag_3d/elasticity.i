E = 6.26e3
nu = 0.2
Gc = 3.656e-2
sigma_ts = 10
sigma_cs = 37.4
rho = 1.995e-9
# l = 1
l = 0.5
delta = 0
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
# psic = ${fparse sigma_ts^2/2/E}

refine = 3 # h_r = 0.125
v0 = -1e4 # mm/s -> 5 m/s -> h0 = 1.27 m
Dt = 20e-6

# hht parameters
hht_alpha = -0.25
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd f_nu_var'
    source_variable = 'd f_nu_var'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y disp_z psie_active'
    source_variable = 'disp_x disp_y disp_z psie_active'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_cs=${sigma_cs};delta=${delta};refine=${refine}'
    execute_on = TIMESTEP_END
    # clone_parent_mesh = true
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = true
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/quarter_cylinder_r20_t30_h1_transfinite.msh'
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
  cycles_per_step = 2
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
    # [psic_marker]
    #   type = ValueThresholdMarker
    #   variable = psie_active
    #   refine = ${fparse psic*0.75}
    # []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker'
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [accel_x]
    outputs = 'none'
  []
  [accel_y]
    outputs = 'none'
  []
  [accel_z]
    outputs = 'none'
  []
  [vel_x]
    outputs = 'none'
  []
  [vel_y]
    outputs = 'none'
  []
  [vel_z]
    outputs = 'none'
  []
  [fx]
    outputs = 'none'
  []
  [fy]
    outputs = 'none'
  []
  [fz]
    outputs = 'none'
  []
  [d]
  []
  [stress_zz]
    order = constant
    family = monomial
  []
  [stress_rr]
    order = constant
    family = monomial
  []
  [s_max]
    order = constant
    family = monomial
  []
  [s_min]
    order = constant
    family = monomial
  []
  [f_nu_var]
    order = constant
    family = monomial
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
  [solid_z]
    type = ADDynamicStressDivergenceTensors
    variable = disp_z
    component = 2
    save_in = fz
  []
  [inertia_x]
    type = ADInertialForce
    variable = disp_x
    density = density
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
    density = density
    velocity = vel_y
    acceleration = accel_y
  []
  [inertia_z]
    type = ADInertialForce
    variable = disp_z
    density = density
    velocity = vel_z
    acceleration = accel_z
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    # execute_on = timestep_end
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    # execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    # execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    # execute_on = timestep_end
  []
  [accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    # execute_on = timestep_end
  []
  [vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    # execute_on = timestep_end
  []
  [stress_rr]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 'stress_rr'
    scalar_type = RadialStress
    execute_on = 'TIMESTEP_END'
  []
  [stress_zz]
    type = ADRankTwoAux
    variable = 'stress_zz'
    rank_two_tensor = 'stress'
    index_i = 2
    index_j = 2
    execute_on = 'TIMESTEP_END'
  []
  [s_max]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 's_max'
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s_min]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 's_min'
    scalar_type = MinPrincipal
    execute_on = 'TIMESTEP_END'
  []
[]

[Functions]
  [load_func]
    type = ADParsedFunction
    expression = 'v0*t'
    symbol_names = 'v0'
    symbol_values = ${v0}
  []
[]

[BCs]
  [load]
    type = ADFunctionDirichletBC
    variable = disp_z
    boundary = load
    function = load_func
  []
  [fix_front_in_y]
    type = ADDirichletBC
    variable = disp_y
    boundary = front
    value = 0
  []
  [fix_left_in_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  # [degradation]
  #   type = RationalDegradationFunction
  #   f_name = g
  #   phase_field = d
  #   material_property_names = 'Gc psic xi c0 l'
  #   parameter_names = 'p a2 a3 eta'
  #   parameter_values = '2 1 0 1e-9'
  # []
  [degradation]
    type = PowerDegradationFunction
    f_name = g 
    function = (1-d)^p+eta
    phase_field = d 
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  # [nodeg]
  #   type = NoDegradation
  #   f_name = g 
  #   phase_field = d 
  #   function = 1
  # []
  [strain]
    type = ADComputeSmallStrain
    # output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = SPECTRAL
    decomposition = NONE
    output_properties = 'psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
  []
[]

[Postprocessors]
  [max_disp_z]
    type = NodalExtremeValue
    value_type = max
    variable = disp_z
  []
  [min_disp_z]
    type = NodalExtremeValue
    value_type = min 
    variable = disp_z
  []
  [max_d]
    type = NodalExtremeValue
    value_type = max
    variable = d
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
                        '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
                        '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
                        '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20

  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-3
  fixed_point_abs_tol = 1e-5

  dt = 1e-7
  start_time = 0
  end_time = 50e-6

  [TimeIntegrator]
    type = NewmarkBeta
    beta = ${beta}
    gamma = ${gamma}
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 5
    minimum_time_interval = 5e-7
  []
  print_linear_residuals = false
  file_base = './out/frag_3d_nuc22_v0${v0}_l${l}_d${delta}/frag'
  interval = 1
  checkpoint = true
  [csv]
    file_base = './gold/frag_3d_nuc22_v0${v0}_l${l}_d${delta}'
    type = CSV
  []
[]