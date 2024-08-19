Gc = 22.2
E = 1.9e5
nu = 0.3
rho = 8e-9 # [Mg/mm^3]
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

sigma_ts = 1733 # MPa
# sigma_cs = 5199
sigma_cs = 1800
# psic = '${fparse sigma_ts^2/2/E}'

# l = 0.35
l = 0.75
# l = 0.2
# l = 1
# delta = 0.5

refine = 4 #h_r = 0.3125
# lch = 3 * Gc * E / 8 / (sts**2) = 0.53, l < lch/4

# hht parameters
hht_alpha = -0.25
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_ldl.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_cs=${sigma_cs};'
               'refine=${refine}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd f_nu'
    source_variable = 'd f_nu'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
  []
  [pp_transfer]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = Psi_f
    to_postprocessor = fracture_energy
    reduction_type = average
  []
  [pp_transfer2]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = ce_integral
    to_postprocessor = nucleation_energy
    reduction_type = average
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  # use_displaced_mesh = true
[]

[Mesh]
  # [gen]
  #   type = FileMeshGenerator
  #   file = './mesh/kal.msh'
  # []
  [gen] #h_c = 5, h_r = 0.15625
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
    xmin = 0
    xmax = 100
    ymin = 0
    ymax = 100
  []
  [sub_upper]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x < 50 & y > 25 & y < 50'
    block_id = 1
  []
  [sub_lower]
    type = ParsedSubdomainMeshGenerator
    input = sub_upper
    combinatorial_geometry = 'x < 50 & y < 25'
    block_id = 2
  []
  [split]
    input = sub_lower
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
  []
  [load] # causing troubles, why？
    input = split
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x) < 0.05 & y < 25'
    new_sideset_name = load
  []
[]

[Adaptivity]
  initial_marker = initial_box
  initial_steps = ${refine}
  marker = combo_marker
  max_h_level = ${refine}
  cycles_per_step = ${refine}
  [Markers]
    # [initial_box]
    #   type = BoxMarker
    #   bottom_left = '44 19 0'
    #   top_right = '56 31 0'
    #   inside = refine
    #   outside = DO_NOTHING
    # []
    [initial_box]
      type = BoxMarker
      bottom_left = '0 0 0'
      top_right = '56 31 0'
      inside = refine
      outside = DO_NOTHING
    []
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    # [psie_marker]
    #   type = ValueThresholdMarker
    #   variable = psie_active
    #   refine = 3
    # []
    [combo_marker]
      type = ComboMarker
      markers = 'initial_box damage_marker'
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
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
  [s1]
    order = CONSTANT
    family = MONOMIAL
  []
  [s2]
    order = CONSTANT
    family = MONOMIAL
  []
  [s3]
    order = CONSTANT
    family = MONOMIAL
  []
  # [s11]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  # [s22]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  # [f_quadrant_1]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  [f_quadrant_2]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_nu]
    order = CONSTANT
    family = MONOMIAL
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
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  []
  [vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  []
  # [s11]
  #   type = ADRankTwoAux
  #   rank_two_tensor = stress
  #   variable = s11
  #   index_i = 0
  #   index_j = 0
  #   execute_on = 'TIMESTEP_END'
  # []
  # [s22]
  #   type = ADRankTwoAux
  #   rank_two_tensor = stress
  #   variable = s22
  #   index_i = 1
  #   index_j = 1
  #   execute_on = 'TIMESTEP_END'
  # []
  [s1]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s1
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s2]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s2
    scalar_type = MidPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s3]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s3
    scalar_type = MinPrincipal
    execute_on = 'TIMESTEP_END'
  []
  # [quadrant]
  #   type = ParsedAux
  #   variable = f_quadrant_1
  #   coupled_variables = 's11 s22'
  #   expression = 'if(s11>=0, if(s22>=0, 1, 4), if(s22>=0, 2, 3))'
  # []
  [quadrant]
    type = ParsedAux
    variable = f_quadrant_2
    coupled_variables = 's1 s3'
    expression = 'if(s1>=0, if(s3>=0, 1, 4), if(s3>=0, 2, 3))'
  []
[]

[Functions]
  [load_func]
    type = ADParsedFunction
    expression = 'if(t<t0, v0/2/t0*t^2, v0*t - 0.5*v0*t0)'
    symbol_names = 'v0 t0'
    symbol_values = '16.5e3 1e-6'
  []
[]

[BCs]
  [xdisp]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = load
    function = load_func
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = bottom
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
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  # [degradation]
  #   type = NoDegradation
  #   f_name = g
  #   phase_field = d
  #   function = 1
  # []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
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
  # [ddt]
  #   type = TimestepSize
  #   outputs = "csv"
  # []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = load
    outputs = "csv exodus"
  []
  [max_disp_x]
    type = NodalExtremeValue
    variable = disp_x
    outputs = "csv exodus"
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
    outputs = "csv exodus"
  []
  # [Jint]
  #   type = PhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'left bottom right top'
  #   outputs = "csv exodus"
  # []
  [fracture_energy]
    type = Receiver
    outputs = "csv"
  []
  [nucleation_energy]
    type = Receiver
    outputs = "csv"
  []
  [kinetic_energy]
    type = KineticEnergy
    outputs = "csv"
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
    outputs = "csv"
  []
  [external_work]
    type = ExternalWork
    boundary = 'load'
    forces = 'fx fy'
    outputs = "csv"
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -ksp_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type -sub_pc_factor_shift_amount ' 
  # petsc_options_value = 'asm      gmres     200                preonly       lu           1  NONZERO 1e-14  '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
  #                       '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
  #                       '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
  #                       '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  start_time = 0
  end_time = 90e-6
  # nl_max_its = 20

  fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = true
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5
  dt = 5e-7
  # dtmin = 1e-8
  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t <= 3.1e-5, 5e-7, 5e-8)'
  #   # type = ConstantDT
  #   # dt = 5e-7
  #   cutback_factor_at_failure = 0.5
  # []
  # [TimeIntegrator]
  #   type = NewmarkBeta
  #   beta = ${beta}
  #   gamma = ${gamma}
  # []
  # [Predictor]
  #   type = SimplePredictor
  #   scale = 1
  # []
[]

[Outputs]
  [exodus]
    type = Exodus
    time_step_interval = 1
    min_simulation_time_interval = 5e-7
  []
  print_linear_residuals = false
  # file_base = './out/na_kal_nuc20_ts${sigma_ts}_cs${sigma_cs}_l${l}_d${delta}/kal_nuc20_ts${sigma_ts}_cs${sigma_cs}_l${l}_d${delta}'
  file_base = './out/kal_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}/kal_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}'
  # interval = 1
  checkpoint = true
  [csv]
    min_simulation_time_interval = 1e-8
    # file_base = './gold/na_kal_nuc20_ts${sigma_ts}_cs${sigma_cs}_l${l}_d${delta}'
    file_base = './out/kal_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}/kal_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}'
    type = CSV
  []
[]
