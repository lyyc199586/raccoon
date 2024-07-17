# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
# rho = 2.45e-9 # Mg/mm^3
rho = 2450
Gc = 3e-3 # N/mm -> 3 J/m^2
sigma_ts = 3.08 # MPa, sts and scs from guessing
# sigma_ts = 6
# sigma_cs = 9.24
psic = ${fparse sigma_ts^2/2/E}

# lch = 3/8*E*Gc/sts^2 (sts=3, lch=4, sts=6, lch=1)
# l = 1.25
# l = 0.25
l = 0.625
# h = 1
# h = 0.5
# delta = 4 # haven't tested
# refine = 3 # 1/2^3 = 0.125
# refine = 4
# h = ${fparse 1/2^refine}
p = 1
# p = 0.8
Tb = 0
Tf = 70

# nx = '${fparse int(100/h)}'
# ny = '${fparse int(40/h)}'

filebase = coh_cf_release_x78_p${p}_l${l}_tb${Tb}_tf${Tf}

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_coh_cf_release.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic}'
    # cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic}'
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
    # variable = 'disp_x disp_y strain_zz psie_active'
    # source_variable = 'disp_x disp_y strain_zz psie_active'
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
  [FE_transfer]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = 'Psi_f'
    to_postprocessor = 'FE'
    reduction_type = average
  []
  # [FE_br_transfer]
  #   type = MultiAppPostprocessorTransfer
  #   from_multi_app = fracture
  #   from_postprocessor = Psi_f_br
  #   to_postprocessor = FE_br
  #   reduction_type = average
  # []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = true
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = "./mesh/br_cf_release_x78.msh"
  []
  construct_node_list_from_side_list = true
  construct_side_list_from_node_list = true
[]

# [Adaptivity]
#   initial_marker = initial
#   initial_steps = ${refine}
#   [Markers]
#     [initial]
#       type = BoxMarker
#       bottom_left = '50 -20 0'
#       top_right = '100 20 0'
#       inside = REFINE
#       outside = DO_NOTHING
#     []
#   []
# []

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
#       lower_bound = 0.0001
#       upper_bound = 1
#     []
#     [psic_marker]
#       type = ValueThresholdMarker
#       variable = psie_active
#       refine = 0.00075
#     []
#     [initial]
#       type = BoxMarker
#       bottom_left = '${fparse 50-h-0.01} -${fparse h+0.01} 0'
#       top_right = '${fparse 50+h+0.01} ${fparse h+0.01} 0'
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
    # initial_from_file_var = 'disp_x'
    # initial_from_file_timestep = LATEST
    # order = SECOND
  []
  [disp_y]
    # initial_from_file_var = 'disp_y'
    # initial_from_file_timestep = LATEST
    # order = SECOND
  []
  # [strain_zz]
  #   # initial_from_file_var = 'strain_zz'
  #   # initial_from_file_timestep = LATEST
  # []
[]

[AuxVariables]
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
    # order = SECOND
    # family = HIERARCHIC
  []
  [vel_y]
    # order = SECOND
    # family = HIERARCHIC
  []
  [fx]
    # order = SECOND
    # family = HIERARCHIC 
  []
  [fy]
    # order = SECOND
    # family = HIERARCHIC 
  []
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=49.5&x<=50.5,1,0)'
    # []
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
  # [f_quadrant_2]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  # [kinetic_energy_var]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  [w_ext]
  []
  [p_ext]
  []
  # [psi_f_var]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
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
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  # []
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
  # [quadrant]
  #   type = ParsedAux
  #   variable = f_quadrant_1
  #   coupled_variables = 's11 s22'
  #   expression = 'if(s11>=0, if(s22>=0, 1, 4), if(s22>=0, 2, 3))'
  # []
  # [quadrant2]
  #   type = ParsedAux
  #   variable = f_quadrant_2
  #   coupled_variables = 's1 s3'
  #   expression = 'if(s1>=0, if(s3>=0, 1, 4), if(s3>=0, 2, 3))'
  # []
  # [kinetic_energy_aux]
  #   type = ADKineticEnergyAux
  #   variable = kinetic_energy_var
  #   density = density
  #   newmark_velocity_x = vel_x
  #   newmark_velocity_y = vel_y
  #   newmark_velocity_z = 0
  # []
  [power]
    type = ParsedAux
    variable = p_ext
    expression = 'abs(vel_y)'
    coupled_variables = 'vel_y'
    boundary = 'top bottom'
  []
  [work]
    type = ParsedAux
    variable = w_ext
    # expression = 'disp_y^2/sqrt(disp_x^2 + disp_y^2) + disp_x^2/sqrt(disp_x^2 + disp_y^2)'
    expression = 'if(x > 0.01, if(x < 99.99, abs(disp_y)*${p}, abs(disp_y)/2*${p}), abs(disp_y)/2*${p})'
    coupled_variables = 'disp_y'
    boundary = 'top bottom'
    use_xyzt = true
  []
[]

# [Functions]
#   [p_func]
#     type = PiecewiseLinear
#     x = '${Tb} ${Tf}'
#     y = '${p} 0'
#   []
# []

[BCs]
  # [ytop]
  #   type = ADPressure
  #   variable = disp_y
  #   boundary = top
  #   function = '${p}'
  #   # function = p_func
  #   factor = 1
  # []
  # [ybottom]
  #   type = ADPressure
  #   variable = disp_y
  #   boundary = bottom
  #   function = '${p}'
  #   # function = p_func
  #   factor = 1
  # []
  [ytop]
    type = ADNeumannBC
    variable = disp_y
    boundary = top
    value = ${fparse p}
  []
  [ybottom]
    type = ADNeumannBC
    variable = disp_y
    boundary = bottom
    value = ${fparse -p}
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
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  # [strain]
  #   type = ADComputePlaneSmallStrain
  #   # out_of_plane_strain = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  #   output_properties = 'total_strain'
  #   outputs = exodus
  # []
  [strain]
    type = ADComputeSmallStrain
    # type = ADComputePlaneSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
    # outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = NONE
    decomposition = SPECTRAL
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
  [Fy_top]
    type = NodalSum
    variable = fy
    boundary = top
    # outputs = "csv exodus"
  []
  [max_disp_y]
    type = NodalExtremeValue
    variable = disp_y
    # outputs = "csv exodus"
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
  # [DJ1_br]
  #   type = DynamicPhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'br_bnd'
  #   density = density
  # []
  # [DJ2_br]
  #   type = DJint
  #   J_direction = '1 0 0'
  #   displacements = 'disp_x disp_y'
  #   velocities = 'vel_x vel_y'
  #   block = '5'
  #   density = density
  # []
  # [DJ_br]
  #   type = ParsedPostprocessor
  #   expression = 'DJ1_br + DJ2_br'
  #   pp_names = 'DJ1_br DJ2_br'
  # []
  [FE]
    type = Receiver
  []
  # [FE_br]
  #   type = Receiver
  # []
  [KE]
    type = KineticEnergy
  []
  # [KE_br]
  #   type = KineticEnergy
  #   block = 5
  # []
  [SE]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  # [SE_br]
  #   type = ADElementIntegralMaterialProperty
  #   mat_prop = psie
  #   block = '5'
  # []
  [EW]
    type = ExternalWork
    boundary = 'top bottom'
    forces = 'fx fy'
  []
  # [EW_br]
  #   type = ExternalWork
  #   boundary = 'br_bnd'
  #   forces = 'fx fy'
  # []
  [PEW]
    type = SideIntegralVariablePostprocessor
    variable = w_ext
    boundary = "top bottom"
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre       boomeramg                 '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'asm'
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8

  # dt = 5e-7
  # end_time = 100e-6
  dt = 0.25
  end_time = ${Tf}

  # restart
  # start_time = 80e-6
  # end_time = 120e-6

  fixed_point_max_its = 10
  # accept_on_max_fixed_point_iteration = true
  accept_on_max_fixed_point_iteration = false
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

[Debug]
  show_mesh_meta_data = true
[]

[Outputs]
  [exodus]
    type = Exodus
    # interval = 5
    time_step_interval = 1
    min_simulation_time_interval = 0.25
  []
  checkpoint = true
  print_linear_residuals = false
  # file_base = './out/dyn_br_nuc22_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}/dyn_br_nuc22_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  # file_base = './out/br_coh_plane_stress_p${p}_l${l}/dyn_br'
  # file_base = './out/br_coh_plane_strain_p${p}_tb${Tb}_tf${Tf}/dyn_br'
  file_base = './out/${filebase}/coh'
  # interval = 1
  time_step_interval = 1
  [csv]
    # file_base = './csv/dyn_br_nuc22_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
    # file_base = './gold/br_coh_plane_stress_p${p}_l${l}'
    # file_base = './gold/br_coh_plane_strain_p${p}_tb${Tb}_tf${Tf}_l${l}_h${}'
    file_base = './gold/${filebase}'
    type = CSV
  []
[]
