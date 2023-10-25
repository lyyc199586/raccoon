# BegoStone's properties
E = 2.735e4
nu = 0.2
Gc = 2.188e-2
sigma_ts = 10
rho = 1.995e-9
l = 1
# delta = 0
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
psic = ${fparse sigma_ts^2/2/E}
refine = 3 # h_r = 0.125
v0 = -5e3 # mm/s -> 0.0005 mm/us

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};refine=${refine}'
    execute_on = TIMESTEP_END
    clone_parent_mesh = true
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = true
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 30
    xmin = -20
    xmax = 20
    ymin = -30
    ymax = 0
  []
  [load]
    type = ParsedGenerateSideset
    input = gen
    combinatorial_geometry = 'abs(x) < 5.1 & y > -0.1'
    new_sideset_name = load
  []
  coord_type = XYZ
[]

[Adaptivity]
  initial_marker = initial
  initial_steps = ${refine}
  marker = damage_marker
  max_h_level = ${refine}
  cycles_per_step = 2
  [Markers]
    [initial]
      type = BoxMarker
      bottom_left = '-5.1 -0.9 0'
      top_right = '5.1 0.1 0'
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
      refine = 0.00075
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker psic_marker'
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  [fx]
  []
  [fy]
  []
  [d]
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
    variable = disp_y
    boundary = load
    function = load_func
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0 1e-9'
  []
  # [nodeg]
  #   type = NoDegradation
  #   f_name = g 
  #   phase_field = d 
  #   function = 1
  # []
  [strain]
    type = ADComputeSmallStrain
    output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    # decomposition = NONE
    output_properties = 'psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
[]

[Postprocessors]
  [max_disp_y]
    type = NodalExtremeValue
    value_type = max
    variable = disp_y
  []
  [min_disp_y]
    type = NodalExtremeValue
    value_type = min 
    variable = disp_y
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
  #                       '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
  #                       '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
  #                       '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20

  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = false
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
    interval = 1
    minimum_time_interval = 1e-7
  []
  print_linear_residuals = false
  file_base = './out/frag_2d_y30_coh_l${l}_v0${v0}/frag_2d_coh_l${l}_v0${v0}'
  interval = 1
  checkpoint = true
  [csv]
    file_base = './gold/frag_2d_y30_coh_l${l}_v0${v0}'
    type = CSV
  []
[]