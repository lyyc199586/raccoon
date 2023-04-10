# BegoStone
E = 6.16e3
nu = 0.2
Gc = 3.656e-2
sigma_ts = 10
sigma_cs = 80
l = 0.25
delta = 25

# R = 2.9 
v = 0.05

# ---------------------------------
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_cs=${sigma_cs};delta=${delta}'
    execute_on = 'TIMESTEP_END'
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
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  coord_type = XYZ
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/disk_mortar_flat.msh'
    ### for recover
    # use_for_exodus_restart = true
    # file = './out/solid_R14.5_ts10_cs80_l0.25_delta25.e'
  []
  patch_size = 10
  patch_update_strategy = always
[]

[Contact]
  [top_contact]
    primary = top_anvil_bottom 
    secondary = top_arc
    model = frictionless
    formulation = mortar
  []
  [bottom_contact]
    primary = bottom_anvil_top
    secondary =  bottom_arc
    model = frictionless
    formulation = mortar
  []
[]

[Variables]
  [disp_x]
    # initial_from_file_var = 'disp_x' 
    # initial_from_file_timestep = LATEST
  []
  [disp_y]
    # initial_from_file_var = 'disp_y' 
    # initial_from_file_timestep = LATEST
  []
  [strain_zz]
    # initial_from_file_var = 'strain_zz' 
    # initial_from_file_timestep = LATEST
  []
[]

[AuxVariables]
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(x=0&x>=-0.5&x<=0.5,1,0)'
    # []
    # initial_from_file_var = 'd' # for restart
    # initial_from_file_timestep = LATEST # for restart
  []
  [f_x]
    # initial_from_file_var = 'f_x' # for restart
    # initial_from_file_timestep = LATEST # for restart
  []
  [f_y]
    # initial_from_file_var = 'f_y' # for restart
    # initial_from_file_timestep = LATEST # for restart
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
  [p]
    order = CONSTANT
    family = MONOMIAL
    # initial_from_file_var = 'p' # for restart
    # initial_from_file_timestep = LATEST # for restart
  []
  [srr]
    order = CONSTANT
    family = MONOMIAL
  []
  [stt]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [solid_r]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = f_x
  []
  [solid_z]
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
[]

[AuxKernels]
  [maxprincipal]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = s1
    scalar_type = MaxPrincipal
    execute_on = timestep_end
  []
  [midprincipal]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = s2
    scalar_type = MidPrincipal
    execute_on = timestep_end
  []
  [minprincipal]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = s3
    scalar_type = MinPrincipal
    execute_on = timestep_end
  []
  [radialstress]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = srr
    scalar_type = RadialStress
    execute_on = timestep_end
  []
  [hoopstress]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = stt
    scalar_type = HoopStress
    execute_on = timestep_end
  []
  [pressure]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = p
    scalar_type = Hydrostatic
    execute_on = timestep_end
  []
[]

[BCs]
  [top_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top_anvil_top
    function = '-${v}*t'
  []
  [top_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = top_anvil_top
    value = 0
  []
  [bottom_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bottom_anvil_bottom
    function = '${v}*t'
  []
  [bottom_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = bottom_anvil_bottom
    value = 0
  []
[]
# [BCs]
  # [top_arc_disp_y]
  #   type = ADFunctionDirichletBC
  #   variable = disp_y
  #   boundary = top_arc
  #   function = top_bc_func
  # []
  # [bot_arc_disp_y]
  #   type = ADFunctionDirichletBC
  #   variable = disp_y
  #   boundary = bot_arc
  #   function = bot_bc_func
  # []
  # [top_arc_disp_y]
  #   type = ADFunctionContactBC
  #   variable = disp_y
  #   boundary = top_arc
  #   function = top_bc_func
  #   penalty_function = p_func
  # []
  # [bot_arc_disp_y]
  #   type = ADFunctionContactBC
  #   variable = disp_y
  #   boundary = bot_arc
  #   function = bot_bc_func
  #   penalty_function = p_func
  # []
  # [fix_top_x]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = fix_point
  #   value = 0
  # []
  ###### pressure 
  # [top_pressure_x]
  #   type = ADPressure
  #   component = 0
  #   variable = disp_x
  #   displacements = 'disp_x disp_y'
  #   boundary = 'top_arc'
  #   function = '1*t'
  #   # function = 'if(y>2.9*cos(0.1*t/180*3.1415926), t, 0)'
  #   use_displaced_mesh = true
  # []
  # [top_pressure_y]
  #   type = ADPressure
  #   component = 1
  #   variable = disp_y
  #   displacements = 'disp_x disp_y'
  #   boundary = 'top_arc'
  #   function = '1*t'
  #   # function = 'if(y>2.9*cos(0.1*t/180*3.1415926), t, 0)'
  #   use_displaced_mesh = true
  # []
  # [bot_pressure_x]
  #   type = ADPressure
  #   component = 0
  #   variable = disp_x
  #   displacements = 'disp_x disp_y'
  #   boundary = 'bot_arc'
  #   function = '1*t'
  #   # function = 'if(y<-2.9*cos(0.1*t/180*3.1415926), t, 0)'
  #   use_displaced_mesh = true
  # []
  # [bot_pressure_y]
  #   type = ADPressure
  #   component = 1
  #   variable = disp_y
  #   displacements = 'disp_x disp_y'
  #   boundary = 'bot_arc'
  #   function = '1*t'
  #   # function = 'if(y<-2.9*cos(0.1*t/180*3.1415926), t, 0)'
  #   use_displaced_mesh = true
  # []
# []

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p+eta #(1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # type = ADComputeSmallStrain
    output_properties = 'total_strain'
    # outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # decomposition = VOLDEV
    output_properties = 'psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
[]

[Postprocessors]
  # [Jint]
  #   type = PhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'left top right bottom'
  # []
  # [Jint_over_Gc]
  #   type = ParsedPostprocessor
  #   function = 'Jint/${Gc}'
  #   pp_names = 'Jint'
  #   use_t = false
  # []
  [top_react]
    type = NodalSum
    variable = f_y
    # boundary = top_point
    boundary = top_arc
  []
  [bot_react]
    type = NodalSum
    variable = f_y
    # boundary = bot_point
    boundary = bottom_arc
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [w_ext_top]
    type = ExternalWork
    displacements = 'disp_y'
    forces = f_y
    # boundary = top_point
    boundary = top_arc
  []
  [w_ext_bottom]
    type = ExternalWork
    displacements = 'disp_y'
    forces = f_y
    # boundary = bot_point
    boundary = bottom_arc
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true
  line_search = bt

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  ### for disp bc
  dt = 0.01
  end_time = 0.02

  ### restart
  # start_time = 0.492
  # end_time = 0.6
  # dt = 2e-3

  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<0.75, 0.05, 2e-3)' # r2/R = infty
  #   # function = 'if(t<0.35, 0.05, 2e-3)' # r2/R = 1.1
  #   # function = 'if(t<0.45, 0.05, 2e-3)' # r2/R = 1.25
  # []

  # fast
  # fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  # # fixed_point_max_its = 50
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-8
  # fixed_point_abs_tol = 1e-10

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  # fixed_point_rel_tol = 1e-5
  # fixed_point_abs_tol = 1e-6
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
  []
  file_base = './out/mortar_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  print_linear_residuals = false
  [csv]
    type = CSV
    # file_base = 'disk'
  []
[]
