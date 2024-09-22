# dynamic branching

# PMMA, MPa, N, mm
# material = pmma
E = 32e3 # 32 GPa
nu = 0.2
# rho = 2.54e-9 # Mg/mm^3
rho = 2.45e3
# rho = 2.45e2
Gc = 0.003
sigma_ts = 3.08 # MPa
# sigma_cs = 9.24
psic = '${fparse sigma_ts^2/2/E}'
l = 0.625

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
c1 = '${fparse (1+nu)*sqrt(Gc)/sqrt(2*pi*E)}'
c2 = '${fparse (3-nu)/(1+nu)}'

# surfing 
# CR=2.128 mm/us
# V = 1
V = 0.2128
# V = 0.4256
# V = 0.8512
t_lag = 20
tf = 150

# shape and scale
a = 10 # crack length
h = 1
length = '${fparse 6*a}'
width = '${fparse 2*a}'
nx = '${fparse length/h}'
ny = '${fparse width/h}'
refine = 3 # fine mesh size: 0.125

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[Functions]
  [bc_func]
    type = ParsedFunction
    expression = c1*((x-V*(t-t_lag))^2+y^2)^(0.25)*(c2-cos(atan2(y,(x-V*(t-t_lag)))))*sin(0.5*atan2(y,(x-V*(t-t_lag))))
    symbol_names = 'c1 c2 V t_lag'
    symbol_values = '${c1} ${c2} ${V} ${t_lag}'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_coh.i
    # cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};nx=${nx};ny=${ny};refine=${refine};length=${length};a=${a}'
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};a=${a}'
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
  # use_displaced_mesh = true
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${nx}
    ny = ${ny}
    xmax = ${length}
    ymin = '${fparse -1*a}'
    ymax = ${a}
  []
  # [gen2]
  #   type = ExtraNodesetGenerator
  #   input = gen
  #   new_boundary = fix_point
  #   coord = '0 ${fparse -1*a}' # fix left bottom point
  # []
  [small]
    input = gen
    type = ParsedSubdomainMeshGenerator
    block_id = 1
    combinatorial_geometry = 'abs(y)<2'
    block_name = small
  []
  [box_bnd]
    input = small 
    type = SideSetsAroundSubdomainGenerator
    block = '1'
    new_boundary = 'box'
  []
  [refine]
    input = box_bnd
    type = RefineBlockGenerator
    block = 1
    refinement = ${refine}
  []
[]

# [Adaptivity]
#   initial_marker = initial_tip
#   initial_steps = ${refine}
#   marker = damage_marker
#   max_h_level = ${refine}
#   [Markers]
#     [damage_marker]
#       type = ValueThresholdMarker
#       variable = d
#       refine = 0.0001
#     []
#     [initial_tip]
#       type = BoxMarker
#       bottom_left = '0 -${fparse 2*l} 0'
#       top_right = '${fparse a + 2*l} ${fparse 2*l} 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#   []
# []

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
  []
[]

[AuxVariables]
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=${a},1,0)'
    []
  []
  [f_x]
  []
  [f_y]
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = f_x
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = f_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
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

[BCs]
  # [fix_x]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = fix_point
  #   value = 0
  # []
  [bottom_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bc_func
  []
  [top_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = bc_func
  []
  [bottom_x]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = bottom
    function = 0
  []
  [top_x]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = top
    function = 0
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${rho} ${psic}'
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
  #   parameter_values = '2 0'
  # []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
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
    output_properties = 'psie psie_active'
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
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right bottom'
  []
  [DJint]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    density = density
    boundary = 'left bottom right top'
  []
  [DJint_2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    block = '0 1'
  []
  [Jint_box]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'box'
  []
  [DJint_box]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    density = density
    boundary = 'box'
  []
  [DJint_box_2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    block = '1'
  []
  [DJ]
    type = ParsedPostprocessor
    expression = 'DJint + DJint_2'
    pp_names = 'DJint DJint_2'
  []
  [DJ_box]
    type = ParsedPostprocessor
    expression = 'DJint_box + DJint_box_2'
    pp_names = 'DJint_box DJint_box_2'
  []
  # [Jint_over_Gc]
  #   type = ParsedPostprocessor
  #   expression = 'Jint/${Gc}'
  #   pp_names = 'Jint'
  #   use_t = false
  # []
  # [DJint_over_Gc]
  #   type = ParsedPostprocessor
  #   expression = 'DJint/${Gc}'
  #   pp_names = 'DJint'
  #   use_t = false
  # []
  [bot_react]
    type = NodalSum
    variable = f_y
    boundary = bottom
  []
  [top_react]
    type = NodalSum
    variable = f_y
    boundary = top
  []
  [fracture_energy]
    type = Receiver
    execute_on = 'timestep_end'
  []
  [kinetic_energy]
    type = KineticEnergy
    execute_on = 'timestep_end'
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
    execute_on = 'timestep_end'
  []
  [external_work]
    type = ExternalWork
    boundary = 'top bottom'
    forces = 'f_x f_y'
    execute_on = 'timestep_end'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  start_time = 0
  end_time = ${tf}
  dt = 0.5
  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<${t_lag},0.5,0.051)'
  # []
  # num_steps = 3

  # fast
  # fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-8
  # fixed_point_abs_tol = 1e-10
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
    type = Exodus
    min_simulation_time_interval = 1
    # time_step_interval = 10
  []
  # file_base = './out/${material}_coh_rho${rho}_tlag${t_lag}_tf${tf}_v${V}_l${l}_h${h}_ref${refine}/${material}_surf'
  file_base = './out/surf_coh_v${V}/surf_coh_v${V}'
  print_linear_residuals = false
  checkpoint = true
  [csv]
    type = CSV
    # file_base = './gold/${material}_coh_rho${rho}_tlag${t_lag}_tf${tf}_v${V}_l${l}_h${h}_ref${refine}'
    file_base = './gold/surf_coh_v${V}'
  []
[]
