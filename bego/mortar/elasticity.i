# # BegoStone
# E = 6.16e3
# nu = 0.2
# Gc = 3.656e-2
# sigma_ts = 10
# sigma_cs = 80
# l = 0.25
# delta = 25
# # steel (for anvil)
# E_s = 2e5 # 200 GPa
# nu_s = 0.31

# Oscar's manuscript
E = 1e4 # start point E
sigma_ts = 10 # s_ts = 1e-3*E
sigma_cs = 80 # s_cs/s_ts = 3, 8, 20
nu = 0.3 # nu = 0.1, 0.3, 0.45
E_s = 1e7 # 1e3*E
nu_s = 0.3
# crack properties (not used)
Gc = 3.656e-2
l = 0.25
delta = 25

# Rp = 1, 1.5, infty # changed with anvial shape 
v = 0.05 # maximum load disp

# ---------------------------------
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

K_s = '${fparse E_s/3/(1-2*nu_s)}'
G_s = '${fparse E_s/2/(1+nu_s)}'

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
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd f_nu_var'
    source_variable = 'd f_nu_var'
    to_blocks = 'disk'
  []
  [to_psie_active]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y psie_active strain_zz'
    source_variable = 'disp_x disp_y psie_active strain_zz'
    from_blocks = 'disk'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  coord_type = XYZ
  [fmg]
    type = FileMeshGenerator
    # file = '../mesh/disk_mortar_flat_h0.01.msh'
    file = '../mesh/disk_mortar_rp1.1_h0.082.msh' # used with adaptivity 
    ### for recover
    # use_for_exodus_restart = true
    # file = './out/solid_R14.5_ts10_cs80_l0.25_delta25.e'
    show_info = true
  []
  [top_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y - 2.9^2) < 0.01 & y > 2'
    new_sideset_name = 'top_arc'
    input = fmg
  []
  [bot_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y - 2.9^2) < 0.01 & y < -2'
    new_sideset_name = 'bot_arc'
    input = top_arc
  []
  [fix_point]
    type = BoundingBoxNodeSetGenerator
    input = bot_arc
    new_boundary = fix_point
    ## for fine meshs
    # bottom_left = '-1e-4 2.8999 0'
    # top_right = '1e-4 2.9001 0'
    ## for corase mesh
    bottom_left = '-0.1 2.8 0'
    top_right = '-0.09 2.9 0'
  []
  patch_size = 100
  patch_update_strategy = always
  # patch_update_strategy = iteration
  # ghosting_patch_size = 10
  # partitioner = centroid
  # use_displaced_mesh = true
[]

[Adaptivity]
  initial_marker = initial
  initial_steps = 3
  max_h_level = 3
  stop_time = 0
  [Markers]
    [initial]
      type = BoxMarker
      # bottom_left = '-1 -3 0'
      # top_right = '1 3 0'
      # bottom_left = '-1.2 -2.901 0'
      # top_right = '1.2 2.901 0'
      bottom_left = '-2 -2.901 0'
      top_right = '2 2.901 0'
      inside = REFINE
      outside = DO_NOTHING
    []
  []
[]

[Contact]
  [top_contact]
    primary = top_anvil_bottom
    secondary = top_arc
    model = frictionless
    formulation = mortar
    # penalty = 1e10
    correct_edge_dropping = true
    c_normal = 1e4
    # normalize_c = true
    # al_penetration_tolerance = 1e-4
  []
  [bottom_contact]
    primary = bottom_anvil_top
    secondary = bot_arc
    model = frictionless
    formulation = mortar
    # penalty = 1e10
    correct_edge_dropping = true
    c_normal = 1e4
    # normalize_c = true
    # al_penetration_tolerance = 1e-4
  []
[]

# [UserObjects]
#   [top_uo]
#     type = PenaltyWeightedGapUserObject
#     primary_boundary = top_anvil_bottom
#     secondary_boundary = top_arc
#     primary_subdomain = top_anvil
#     secondary_subdomain = disk
#     disp_x = disp_x
#     disp_y = disp_y
#     penalty = 1e8
#   []
#   [bot_uo]
#     type = PenaltyWeightedGapUserObject
#     primary_boundary = bottom_anvil_top
#     secondary_boundary = bot_arc
#     primary_subdomain = bottom_anvil
#     secondary_subdomain = disk
#     disp_x = disp_x
#     disp_y = disp_y
#     penalty = 1e8
#   []
# []

# [Constraints]
#   [top_x]
#     type = NormalMortarMechanicalContact
#     primary_boundary = top_anvil_bottom
#     secondary_boundary = top_arc
#     primary_subdomain = top_anvil
#     secondary_subdomain = disk
#     component = x
#     use_displaced_mesh = true
#     compute_lm_residuals = false
#     weighted_gap_uo = top_uo
#   []
#   [top_y]
#     type = NormalMortarMechanicalContact
#     primary_boundary = top_anvil_bottom
#     secondary_boundary = top_arc
#     primary_subdomain = top_anvil
#     secondary_subdomain = disk
#     component = y
#     use_displaced_mesh = true
#     compute_lm_residuals = false
#     weighted_gap_uo = top_uo
#   []
#   [bot_x]
#     type = NormalMortarMechanicalContact
#     primary_boundary = bottom_anvil_top
#     secondary_boundary = bot_arc
#     primary_subdomain = bottom_anvil
#     secondary_subdomain = disk
#     component = x
#     use_displaced_mesh = true
#     compute_lm_residuals = false
#     weighted_gap_uo = bot_uo
#   []
#   [bot_y]
#     type = NormalMortarMechanicalContact
#     primary_boundary = bottom_anvil_top
#     secondary_boundary = bot_arc
#     primary_subdomain = bottom_anvil
#     secondary_subdomain = disk
#     component = y
#     use_displaced_mesh = true
#     compute_lm_residuals = false
#     weighted_gap_uo = bot_uo
#   []
# []

[Variables]
  [disp_x]
    # initial_from_file_var = 'disp_x' 
    # initial_from_file_timestep = LATEST
    # block = 'disk top_anvil bottom_anvil'
  []
  [disp_y]
    # initial_from_file_var = 'disp_y' 
    # initial_from_file_timestep = LATEST
    # block = 'disk top_anvil bottom_anvil'
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
    # block = 'disk top_anvil bottom_anvil'
  []
  [f_x]
    # initial_from_file_var = 'f_x' # for restart
    # initial_from_file_timestep = LATEST # for restart
    # block = 'disk top_anvil bottom_anvil'
  []
  [f_y]
    # initial_from_file_var = 'f_y' # for restart
    # initial_from_file_timestep = LATEST # for restart
    # block = 'disk top_anvil bottom_anvil'
  []
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [penetration]
  []
[]

[Kernels]
  [solid_r]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = f_x
    block = 'disk top_anvil bottom_anvil'
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = f_y
    block = 'disk top_anvil bottom_anvil'
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
    block = 'disk top_anvil bottom_anvil'
  []
[]

[AuxKernels]
  [penetration]
    type = PenetrationAux
    variable = penetration
    boundary = top_anvil_bottom
    paired_boundary = top_arc
  []
  #   [maxprincipal]
  #     type = ADRankTwoScalarAux
  #     rank_two_tensor = 'stress'
  #     variable = s1
  #     scalar_type = MaxPrincipal
  #     execute_on = timestep_end
  #     block = 'disk'
  #   []
  #   [midprincipal]
  #     type = ADRankTwoScalarAux
  #     rank_two_tensor = 'stress'
  #     variable = s2
  #     scalar_type = MidPrincipal
  #     execute_on = timestep_end
  #     block = 'disk'
  #   []
  #   [minprincipal]
  #     type = ADRankTwoScalarAux
  #     rank_two_tensor = 'stress'
  #     variable = s3
  #     scalar_type = MinPrincipal
  #     execute_on = timestep_end
  #     block = 'disk'
  #   []
  #   [radialstress]
  #     type = ADRankTwoScalarAux
  #     rank_two_tensor = 'stress'
  #     variable = srr
  #     scalar_type = RadialStress
  #     execute_on = timestep_end
  #     block = 'disk'
  #   []
  #   [hoopstress]
  #     type = ADRankTwoScalarAux
  #     rank_two_tensor = 'stress'
  #     variable = stt
  #     scalar_type = HoopStress
  #     execute_on = timestep_end
  #     block = 'disk'
  #   []
  #   [pressure]
  #     type = ADRankTwoScalarAux
  #     rank_two_tensor = 'stress'
  #     variable = p
  #     scalar_type = Hydrostatic
  #     execute_on = timestep_end
  #     block = 'disk'
  #   []
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
  [fix_top_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = fix_point
    value = 0
  []
[]

[Materials]
  # bego
  [bulk_properties_bego]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
    block = 'disk'
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  [nodegradation]
    type = NoDegradation
    f_name = g
    function = 1
    phase_field = d
    block = 'disk'
  []
  # [crack_geometric]
  #   type = CrackGeometricFunction
  #   f_name = alpha
  #   function = 'd'
  #   phase_field = d
  # []
  [strain_bego]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # type = ADComputeSmallStrain  
    # output_properties = 'total_strain'
    # outputs = exodus
    block = 'disk'
  []
  [elasticity_bego]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # decomposition = VOLDEV
    output_properties = 'psie_active'
    outputs = exodus
    block = 'disk'
  []
  [stress_bego]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity_bego
    output_properties = 'stress'
    block = 'disk'
    outputs = exodus
  []

  # steel
  [elasticity_steel]
    type = ADComputeIsotropicElasticityTensor
    bulk_modulus = ${K_s}
    shear_modulus = ${G_s}
    block = 'top_anvil bottom_anvil'
  []
  [stress_steel]
    type = ADComputeLinearElasticStress
    block = 'top_anvil bottom_anvil'
    # outputs = exodus
  []
  [strain_steel]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    block = 'top_anvil bottom_anvil'
  []
[]

[Postprocessors]
  [top_react]
    type = NodalSum
    variable = f_y
    boundary = top_anvil_top
  []
  [bot_react]
    type = NodalSum
    variable = f_y
    boundary = bottom_anvil_bottom
  []
  [max_penetration]
    type = NodalMaxValue
    variable = penetration
  []
[]

[Executioner]
  type = Transient
  # solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_linesearch_type'
  # petsc_options_value = 'lu       superlu_dist                 basic'
  # automatic_scaling = true
  # line_search = none

  # moose tutorial settings
  solve_type = 'PJFNK'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -snes_linesearch_type -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu       basic                 NONZERO               1e-15'
  # petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_ksp_ew'
  # petsc_options_iname = '-pc_type -mat_mffd_err -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       1e-5          NONZERO               1e-15'
  line_search = none
  # line_search = bt
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  l_max_its = 40
  l_abs_tol = 1e-08
  l_tol = 1e-08

  ### for disp bc
  # dt = 0.01
  # end_time = 0.2
  dt = 0.05
  # dt = 0.025
  end_time = 1

  ### restart
  # start_time = 0.492
  # end_time = 0.6
  # dt = 2e-3

  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<0.1, 0.01, 0.05)' # r2/R = infty
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
  # num_steps = 3
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
  []
  # file_base = './out/nodamage/flat/bego_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  file_base = './out/nodamage/plan_stress_rp1.1_E${E}_nu${nu}_ts${sigma_ts}_cs${sigma_cs}'
  print_linear_residuals = false
  [csv]
    type = CSV
    # file_base = 'disk'
  []
[]
