# 
G = 31.44e-3 # MPa
K = '${fparse 10*G}'
E = '${fparse 9*K*G/(3*K+G)}'

rho = 1e-3
Gc = 0.0247

# sigma_ts = 0.01
sigma_ts = 0.002
psic = ${fparse sigma_ts^2/2/E}

# lch = 3/8*E*Gc/sts^2
l = 2
h = 0.5

# u = 4.5
u = 1
# u = 27
Tf = 10

# hht parameters
hht_alpha = -0.3
# hht_alpha = 0
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

filebase = free_coh_sts${sigma_ts}_u${u}_l${l}_h${h}_y2l

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_coh.i
    # cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};refine=${refine}'
    cli_args = 'K=${K};G=${G};Gc=${Gc};l=${l};psic=${psic}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
    # variable = 'disp_x disp_y psie_active'
    # source_variable = 'disp_x disp_y psie_active'
  []
  [FE_transfer]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = Psi_f
    to_postprocessor = FE
    reduction_type = average
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'pre_free_u${u}_h${h}.e'
    use_for_exodus_restart = true
  []
  [top_layer]
    type = ParsedSubdomainMeshGenerator
    input = fmg
    combinatorial_geometry = 'y >= 2'
    block_id = '1'
    block_name = 'top'
  []
  [bottom_layer]
    type = ParsedSubdomainMeshGenerator
    input = top_layer
    combinatorial_geometry = 'y <= -2'
    block_id = '2'
    block_name = 'bottom'
  []
[]

# [Adaptivity]
#   marker = combo_marker
#   max_h_level = ${refine}
#   initial_marker = initial
#   initial_steps = ${refine}
#   cycles_per_step = ${refine}
#   [Markers]
#     [damage_marker]
#       type = ValueRangeMarker
#       variable = d
#       lower_bound = 0.01
#       upper_bound = 1
#     []
#     [psie_marker]
#       type = ValueThresholdMarker
#       variable = psie_active
#       refine = '${fparse 0.9*psic}'
#     []
#     [initial]
#       type = BoxMarker
#       bottom_left = '9.9 -1.1 0'
#       top_right = '11.1 1.1 0'
#       inside = REFINE
#       outside = DONT_MARK
#     []
#     [combo_marker]
#       type = ComboMarker
#       markers = 'damage_marker initial'
#     []
#   []
# []

[Variables]
  [disp_x]
    initial_from_file_var = 'disp_x'
    initial_from_file_timestep = LATEST
  []
  [disp_y]
    initial_from_file_var = 'disp_y'
    initial_from_file_timestep = LATEST
  []
  [strain_zz]
    # initial_from_file_var = 'strain_zz'
    # initial_from_file_timestep = LATEST
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
  [F]
    order = CONSTANT
    family = MONOMIAL
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
  [hoop]
    order = CONSTANT
    family = MONOMIAL
  []
  [vms]
    order = CONSTANT
    family = MONOMIAL
  []
  [hydrostatic]
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
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
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
  [hoop]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hoop
    scalar_type = HoopStress
    execute_on = 'TIMESTEP_END'
  []
  [hydrostatic]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hydrostatic
    scalar_type = Hydrostatic
    execute_on = 'TIMESTEP_END'
  []
  [vms]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = vms
    scalar_type = VonMisesStress
    execute_on = 'TIMESTEP_END'
  []
  [F]
    type = ADRankTwoAux
    variable = F
    rank_two_tensor = deformation_gradient
    index_i = 1
    index_j = 1
  []
[]

[BCs]
  [ytop]
    type = ADDirichletBC
    variable = disp_y
    boundary = top
    value = ${u}
    # value = 0
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = bottom
    value = -${u}
    # value = 0
  []
  [xtop]
    type = ADDirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
  [xbottom]
    type = ADDirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'K G l Gc density psic'
    prop_values = '${K} ${G} ${l} ${Gc} ${rho} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0.0 1e-6'
  []
  [cnh]
    type = CNHIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active'
    outputs = 'exodus'
  []
  [stress]
    type = ComputeLargeDeformationStress
    elasticity_model = cnh
    output_properties = 'stress'
    outputs = 'exodus'
  []
  [defgrad]
    type = ComputePlaneDeformationGradient
    out_of_plane_strain = strain_zz
  []
[]

[Postprocessors]
  [Fy_top]
    type = NodalSum
    variable = fy
    boundary = top
  []
  [J]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    # outputs = "csv exodus"
  []
  [DJ1]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    density = density
    # outputs = "csv exodus"
  []
  [DJ2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    density = density
  []
  [DJint]
    type = ParsedPostprocessor
    expression = 'DJ1 + DJ2'
    pp_names = 'DJ1 DJ2'
  []
  [KE]
    type = KineticEnergy
  []
  [SE]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [EW]
    type = ExternalWork
    boundary = 'top bottom'
    forces = 'fx fy'
  []
  [FE] # fracture energy
    type = Receiver
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'hypre       boomeramg                 '
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'asm'
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-4
  # nl_abs_tol = 1e-6

  # dt = 5e-7
  # end_time = 100e-6
  dt = 0.025
  # dt = 0.25
  end_time = ${Tf}

  # restart
  # start_time = 80e-6
  # end_time = 120e-6

  fixed_point_max_its = 50
  # accept_on_max_fixed_point_iteration = false
  accept_on_max_fixed_point_iteration = true
  # fixed_point_rel_tol = 1e-8
  # fixed_point_abs_tol = 1e-10
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  # [Quadrature]
  #   type = GAUSS
  #   order = FOURTH
  # []
  # [TimeIntegrator]
  #   type = NewmarkBeta
  # []
[]

[Outputs]
  [exodus]
    type = Exodus
    # time_step_interval = 1
    min_simulation_time_interval = 0.25
  []
  checkpoint = true
  print_linear_residuals = false
  file_base = './out/${filebase}'
  time_step_interval = 1
  [csv]
    file_base = './gold/${filebase}/coh'
    type = CSV
  []
[]
