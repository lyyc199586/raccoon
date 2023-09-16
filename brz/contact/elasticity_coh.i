# 2D plane stress, dynamic simualtions of brazilian tests using contact

# basalt properties (MPa, N, mm, s)
E = 20.11e3
nu = 0.24
Gc = 0.1
sigma_ts = 11.31
# sigma_cs = 159.08
# sigma_cs = ${fparse sigma_ts*30}
rho = 2.74e-9

# steel for platens
E_s = 1e7
nu_s = 0.3
rho_s = 8e-9

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
psic = '${fparse sigma_ts^2/2/E}'

K_s = '${fparse E_s/3/(1-2*nu_s)}'
G_s = '${fparse E_s/2/(1+nu_s)}'

# cohesive model
l = 3

# model parameter
r = 25
a = 20 # load arc angle (deg)
# p = 100
u = 1 # max load disp
t0 = 100e-6 # ramp time
# tf = 200e-6
tf = 100e-6
gap = -0.0145

# adaptivity
# refine = 2 # h_fine ~ 0.2 (0.2-0.25)
refine = 3 # h_fine ~ 0.1 (0.1-0.125)

# hht parameters
hht_alpha = -0.25
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

# newmark beta
# beta = 0.25
# gamma = 0.5

# central difference
# beta = 0
# gamma = 0.5

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture_coh.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};a=${a};r=${r};refine=${refine}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
    to_blocks = 'disc'
  []
  [to_psie_active]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
    from_blocks = 'disc'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  use_displaced_mesh = true
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/disc_contact_r25_h1.msh'
  []
  [left_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x < -${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'left_arc'
    input = fmg
  []
  [right_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x > ${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'right_arc'
    input = left_arc
  []
  [fix_point]
    type = BoundingBoxNodeSetGenerator
    input = right_arc
    new_boundary = fix_point
    bottom_left = '-24.9 0.85 -0.01'
    top_right = '25.1 0.855 0.01'
  []
  [left_platen_set]
    type = BoundingBoxNodeSetGenerator
    input = fix_point
    new_boundary = left_platen_set
    bottom_left = '-31.01 -15.1 -0.01'
    top_right = '-24.99 15.1 0.01'
  []
  [right_platen_set]
    type = BoundingBoxNodeSetGenerator
    input = left_platen_set
    new_boundary = right_platen_set
    bottom_left = '24.99 -15.1 -0.01'
    top_right = '31.01 15.1 0.01'
  []
  # construct_side_list_from_node_list=true
[]

[Contact]
  [left_contact]
    primary = left_platen_right
    secondary = left_arc 
    model = frictionless
    # formulation = mortar
    formulation = penalty
    penalty = 1e+8
    normalize_penalty = true
    secondary_gap_offset = gap
  []
  [right_contact]
    primary = right_platen_left
    secondary = right_arc
    model = frictionless
    # formulation = mortar
    formulation = penalty
    penalty = 1e+8
    normalize_penalty = true
    secondary_gap_offset = gap
  []
[]

[Adaptivity]
  initial_marker = initial_marker
  initial_steps = ${refine}
  # marker = damage_marker
  max_h_level = ${refine}
  [Markers]
    # [damage_marker]
    #   type = ValueRangeMarker
    #   variable = d
    #   lower_bound = 0.0001
    #   upper_bound = 1
    # []
    # [strength_marker]
    #   type = ValueRangeMarker
    #   variable = f_nu_var
    #   lower_bound = -1e-2
    #   upper_bound = 1e-2
    # []
    # [combo_marker]
    #   type = ComboMarker
    #   markers = 'damage_marker combo_marker'
    # []
    [initial_marker]
      type = BoxMarker
      bottom_left = '-${r} -8 0'
      top_right = '${r} 8 0'
      outside = DO_NOTHING
      inside = REFINE
      # outside = COARSEN
      # inside = DO_NOTHING
    []
  []
[]

[Functions]
  [load]
    type = ADParsedFunction
    # expression = 'if(t<t0, p*sin(pi*t/2/t0), p)'
    # expression = 'u*sin(pi*t/2/t0)' # sin
    # expression = 'p*(-cos(pi*t/t0) + 1)/2'
    # symbol_names = 'p t0'
    # symbol_values = '${p} ${t0}'
    expression = 'u*(-cos(pi*t/t0) + 1)/2' # cos 
    # expression = 'u*(3*(t/t0)^2 - 2*(t/t0)^3)' #cubic
    symbol_names = 'u t0'
    symbol_values = '${u} ${t0}'
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
  [d]
  []
  [fx]
  []
  [fy]
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  [penetration]
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
  [s11]
    order = CONSTANT
    family = MONOMIAL
  []
  [s22]
    order = CONSTANT
    family = MONOMIAL
  []
  [s33]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_quadrant_1]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_quadrant_2]
    order = CONSTANT
    family = MONOMIAL
  []
  [gap]
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
    # alpha = 0.1
    save_in = fx
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    # alpha = 0.1
    save_in = fy
  []
  # [solid_x]
  #   type = ADStressDivergenceTensors
  #   variable = disp_x
  #   component = 0
  #   save_in = fx
  #   block = '1 2 3'
  # []
  # [solid_y]
  #   type = ADStressDivergenceTensors
  #   variable = disp_y
  #   component = 1
  #   save_in = fy
  #   block = '1 2 3'
  # []
  [inertia_x]
    type = ADInertialForce
    variable = disp_x
    density = density
    velocity = vel_x
    acceleration = accel_x
    block = '1'
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
    density = density
    velocity = vel_y
    acceleration = accel_y
    block = '1'
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
    block = '1 2 3'
  []
[]

[AuxKernels]
  [accel_x] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  []
  [vel_x] # Calculates and stores velocity at the end of the time step
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
  [penetration]
    type = PenetrationAux
    variable = penetration
    boundary = left_platen_right
    paired_boundary = left_arc
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
  [s11]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = s11
    index_i = 0
    index_j = 0
    execute_on = 'TIMESTEP_END'
  []
  [s22]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = s22
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  []
  [s33]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = s33
    index_i = 2
    index_j = 2
    execute_on = 'TIMESTEP_END'
  []
  [quadrant]
    type = ParsedAux
    variable = f_quadrant_1
    coupled_variables = 's11 s22'
    expression = 'if(s11>=0, if(s22>=0, 1, 4), if(s22>=0, 2, 3))'
  []
  [quadrant2]
    type = ParsedAux
    variable = f_quadrant_2
    coupled_variables = 's1 s3'
    expression = 'if(s1>=0, if(s3>=0, 1, 4), if(s3>=0, 2, 3))'
  []
  [gap]
    type = ConstantAux
    variable = gap
    value = ${gap}
    boundary = 'left_arc right_arc'
  []
[]

[BCs]
  [fix_right_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'right_platen_left'
    # boundary = right_platen_set
    preset = true
    value = 0
  []
  [load_left_x]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = 'left_platen_set'
    preset = true
    function = load
  []
  # [load_left_x]
  #   type = ADPressure
  #   variable = disp_x
  #   boundary = left_platen_right
  #   # boundary = left_platen_set
  #   function = load
  # []
  [fix_center_y]
    type = DirichletBC
    variable = disp_y
    boundary = fix_point
    value = 0
  []
[]


[Materials]
  # disc
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho} ${psic}'
    block = 'disc'
  []
  # [nodegradation] # elastic test
  #   type = NoDegradation
  #   f_name = g 
  #   function = 1
  #   phase_field = d
  #   block = 'disc'
  # []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   # function = (1-d)^p*(1-eta)+eta
  #   function = (1-d)^p+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  #   # parameter_values = '2 0'
  #   block = 'disc'
  # []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
    block = 'disc'
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d 
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta '
    parameter_values = '2 1.0 0.0 1e-3'
    block = 'disc'
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
    block = 'disc'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    output_properties = 'psie_active'
    outputs = exodus
    block = 'disc'
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
    block = 'disc'
  []

  # steel for platen
  [steel_density]
    type = GenericConstantMaterial
    prop_names = 'reg_density'
    prop_values = '${rho_s}'
    block = 'left_platen right_platen'
  []
  [elasticity_steel]
    type = ADComputeIsotropicElasticityTensor
    bulk_modulus = ${K_s}
    shear_modulus = ${G_s}
    block = 'left_platen right_platen'
  []
  [stress_steel]
    type = ADComputeLinearElasticStress
    block = 'left_platen right_platen'
  []
  [strain_steel]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    block = 'left_platen right_platen'
  []
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = left_platen_left
    outputs = 'pp exodus'
  []
  [Fx_left_platen_right]
    type = NodalSum
    variable = fx
    boundary = left_platen_right
    outputs = 'pp exodus'
  []
  [Fx_left_arc]
    type = NodalSum
    variable = fx
    boundary = left_arc
    outputs = 'pp exodus'
  []
  [impactor_disp]
    type = SideAverageValue
    variable = disp_x
    boundary = 'left_platen_right'
    outputs = 'pp exodus'
  []
  [max_d]
    type = NodalMaxValue
    variable = d
    outputs = 'pp exodus'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -ksp_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type -sub_pc_factor_shift_amount ' 
  # petsc_options_value = 'asm      gmres     200                preonly       lu           1  NONZERO 1e-14  '
  automatic_scaling = true

  line_search = l2

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  # dt = 5e-8 # 0.05 us
  dt = 1e-6
  dtmin = 5e-8
  end_time = ${tf}


  fixed_point_max_its = 300
  # fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  # [TimeIntegrator]
  #   type = CentralDifference
  #   solve_type = consistent
  # []
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 1e-6
    interval = 1
  []
  print_linear_residuals = false
  file_base = './out/penalty_coh_u${u}_a${a}_l${l}/penalty_coh_u${u}_a${a}_l${l}'
  interval = 1
  checkpoint = true
  [pp]
    type = CSV
    file_base = './csv/pp_penalty_coh_u${u}_a${a}_l${l}'
  []
[]

