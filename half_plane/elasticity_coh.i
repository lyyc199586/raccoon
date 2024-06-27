# # PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
# rho = 2.45e-9 # Mg/mm^3
rho = 2450
Gc = 3e-3 # N/mm -> 3 J/m^2
# sigma_ts = 3.08 # MPa, sts and scs from guessing
sigma_ts = 6
# sigma_cs = 9.24

# Zhao's thesis
# E = 3.09e3
# nu = 0.35
# rho = 1180
# sigma_ts = 75
# Gc = 2.483

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
psic = '${fparse sigma_ts^2/2/E}'

# lch = 3/8*E*Gc/sts^2 = 1.15
# l = 0.625
l = 0.5
# refine = 2
refine = 3
u0 = 0.005
Tp = 59
Tf = 60

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_coh.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};refine=${refine}'
    # cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

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
  [pp_transfer]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = Psi_f
    to_postprocessor = fracture_energy
    reduction_type = average
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
  # [fmg]
  #   type = FileMeshGenerator
  #   file = 'pre_load_u0.0025.e'
  #   use_for_exodus_restart = true
  # []
  [gen] #h_c = 1, h_r = 0.25
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 40
    xmin = 0
    xmax = 100
    ymin = -20
    ymax = 20
  []
  [sub_upper]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x < 50 & y > 0'
    block_id = 1
  []
  [sub_lower]
    type = ParsedSubdomainMeshGenerator
    input = sub_upper
    combinatorial_geometry = 'x < 50 & y < 0'
    block_id = 2
  []
  [split]
    input = sub_lower
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
  []
  # [damage_region]
  #   type = ParsedSubdomainMeshGenerator
  #   input = split
  #   combinatorial_geometry = 'abs(y) < 12'
  #   block_id = 3
  # []
[]

[Adaptivity]
  marker = combo_marker
  max_h_level = ${refine}
  initial_marker = initial
  initial_steps = ${refine}
  cycles_per_step = ${refine}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.01
      upper_bound = 1
    []
    [initial]
      type = BoxMarker
      # bottom_left = '3.76 -0.26 0'
      # top_right = '4.24 0.26 0'
      bottom_left = '48.9 -1.1 0'
      top_right = '51.1 1.1 0'
      inside = REFINE
      outside = DONT_MARK
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker initial'
    []
  []
[]

[Variables]
  [disp_x]
    # initial_from_file_var = disp_x
    # initial_from_file_timestep = LATEST
  []
  [disp_y]
    # initial_from_file_var = 'disp_y'
    # initial_from_file_timestep = LATEST
  []
  # [strain_zz]
  #   initial_from_file_var = 'strain_zz'
  #   initial_from_file_timestep = LATEST
  # []
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
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = strain_zz
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
[]



[Functions]
  [top_func]
    type = PiecewiseLinear
    x = '0 ${Tp} ${Tf}'
    y = '0 ${u0} ${u0}'
  []
  [bottom_func]
    type = PiecewiseLinear
    x = '0 ${Tp} ${Tf}'
    y = '0 -${u0} -${u0}'
  []
  # [top_func]
  #   type = ADParsedFunction
  #   expression = '1e-6*t^2'
  # []
  # [bottom_func]
  #   type = ADParsedFunction
  #   expression = '-1e-6*t^2'
  # []
[]

[BCs]
  [ytop]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top
    function = top_func
    # function = ${u0}
  []
  [ybottom]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bottom_func
    # function = -${u0}
  []
  # [xtop]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = top
  #   value = 0
  # []
  # [xbottom]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = bottom
  #   value = 0
  # []
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
    # parameter_values = '2 1 0.0 1e-6'
    parameter_values = '2 1 0.0 1e-5'
  []
  [strain]
    type = ADComputeSmallStrain
    # type =  ADComputePlaneSmallStrain
    # out_of_plane_strain = strain_zz
    displacements = 'disp_x disp_y'
    # outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = SPECTRAL
    decomposition = NONE
    output_properties = 'psie_active psie'
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
  [DJint_1]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    # outputs = "csv exodus"
  []
  [DJint_2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    # block = '0 1'
  []
  [DJ]
    type = ParsedPostprocessor
    expression = 'DJint_1 + DJint_2'
    pp_names = 'DJint_1 DJint_2'
  []
  [fracture_energy]
    type = Receiver
    # outputs = "csv"
    execute_on = 'timestep_end'
  []
  [kinetic_energy]
    type = KineticEnergy
    # outputs = "csv"
    execute_on = 'timestep_end'
    # implicit = false
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
    outputs = "exodus csv"
    execute_on = 'timestep_end'
  []
  [external_work]
    type = ExternalWork
    boundary = 'top bottom'
    forces = 'fx fy'
    outputs = "exodus csv"
    execute_on = 'initial timestep_end'
    # unique_node_execute = true
    # force_postaux = true
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre       boomeramg                 '
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'asm'
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  # dt = 5e-7
  # end_time = 100e-6
  [TimeStepper]
    type = FunctionDT
    function = 'if(t>${Tp}, 0.25, 0.05)'
  []
  # dt = 0.25
  end_time = ${Tf}

  # restart
  # start_time = 80e-6
  # end_time = 120e-6

  fixed_point_max_its = 5
  # accept_on_max_fixed_point_iteration = false
  accept_on_max_fixed_point_iteration = true

  fixed_point_rel_tol = 1e-4
  fixed_point_abs_tol = 1e-6

[]

[Outputs]
  [exodus]
    type = Exodus
    min_simulation_time_interval = 0.25
  []
  print_linear_residuals = false
  # file_base = './out/coh_no_split_sts${sigma_ts}_rho${rho}_u${u0}_l${l}_tp${Tp}_tf${Tf}_cf/coh'
  file_base = './out/coh_sts${sigma_ts}_rho${rho}_u${u0}_l${l}_tp${Tp}_tf${Tf}/coh'
  time_step_interval = 1
  [csv]
    # file_base = './gold/coh_no_split_sts${sigma_ts}_rho${rho}_u${u0}_l${l}_tp${Tp}_tf${Tf}'
    file_base = './gold/coh_sts${sigma_ts}_rho${rho}_u${u0}_l${l}_tp${Tp}_tf${Tf}'
    type = CSV
  []
[]
