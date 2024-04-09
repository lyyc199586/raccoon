# soda-lime glass
E = 72e3 # 32 GPa
nu = 0.25
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2.44e-9 # Mg/mm^3
# Gc = 8.89e-3 # N/mm -> 3 J/m^2
# Gc = 8.5e-3
Gc = 9e-3
# Gc = 15e-3
# Gc = 9.5e-3
# Gc = 8.7e-3
# sigma_ts = 41 # MPa, sts and scs from guessing
sigma_ts = 30
psic = ${fparse sigma_ts^2/2/E}
# sigma_cs = 330
# p = 25
# p = 60
p = 106

# l = 0.075
# delta = -0.2 # haven't tested
# refine = 6 # h=1, h_ref=0.015625=1/2^6
refine = 4

l = 0.25
# delta = -0.625
# delta = -0.65
# delta = 0

# hht parameters
# hht_alpha = -0.3
hht_alpha = -0.25
# hht_alpha = 0
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

# putty
E_p = 1.7
nu_p = 0.4
rho_p = 1e-9
K_p = '${fparse E_p/3/(1-2*nu_p)}'
G_p = '${fparse E_p/2/(1+nu_p)}'

# steel
E_s = 200e3
nu_s = 0.3
rho_s = 8e-9
K_s = '${fparse E_s/3/(1-2*nu_s)}'
G_s = '${fparse E_s/2/(1+nu_s)}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = true
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture-coh.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};refine=${refine}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
    to_blocks = 0
  []
  [to_psie_active]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
    from_blocks = 0
  []
[]

[Functions]
#   # [p_func] # trapezoidal loading pulse
#   #   type = PiecewiseLinear
#   #   x = '0 15e-6 60e-6 75e-6 80e-6'
#   #   y = '0 ${p} ${p} 0 0'
#   # []
  [p_func] # trapezoidal loading pulse
    type = PiecewiseLinear
    x = '0 15e-6 115e-6 130e-6'
    y = '0 ${p} ${p} 0'
  []
#   # [t_factor_x]
#   #   type = ADParsedFunction
#   #   expression = 'sin(20/180*pi) + 0.35*cos(20/180*pi)'
#   # []
#   # [t_factor_y]
#   #   type = ADParsedFunction
#   #   expression = 'cos(20/180/pi) - 0.35*sin(20/180*pi)'
#   # []
#   # [t_func_x]
#   #   type = CompositeFunction
#   #   functions = 'p_func t_factor_x'
#   # []
#   # [t_func_y]
#   #   type = CompositeFunction
#   #   functions = 'p_func t_factor_y'
#   # []
[]

[Mesh]
  [gen]
    type = FileMeshGenerator
    # file = '../mesh/half.msh'
    file = '../mesh/half_contact_part.msh'
  []
  [toplayer]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'y > 74'
    block_id = 2
    block_name = top_layer
  []
  # [noncrack]
  #   type = BoundingBoxNodeSetGenerator
  #   input = toplayer
  #   new_boundary = noncrack
  #   bottom_left = '26.9 0 0'
  #   top_right = '100.1 0 0'
  # []
  [noncrack]
    type = ParsedGenerateSideset
    input = toplayer
    new_sideset_name = noncrack
    combinatorial_geometry = 'x > 26.9 & y < 0.1'
  []
  # [vpartialtop]
  #   type = ParsedGenerateSideset
  #   input = noncrack
  #   # included_boundaries = 'v-partial'
  #   included_boundaries = 'v-entire'
  #   new_sideset_name = 'v-load'
  #   combinatorial_geometry = 'x < 13.6'
  # []
  # [striker_bnd]
  #   type = BoundingBoxNodeSetGenerator
  #   input = noncrack
  #   new_boundary = striker_bnd
  #   bottom_left = '-2123 0 0'
  #   top_right = '-1817.09 12.66 0'
  # []
  # construct_side_list_from_node_list = true
  coord_type = XYZ
  patch_update_strategy = always
[]

[Adaptivity]
  initial_marker = initial_tip
  initial_steps = ${refine}
  marker = damage_marker
  max_h_level = ${refine}
  [Markers]
    [damage_marker]
      type = ValueThresholdMarker
      variable = d
      refine = 0.001
    []
    [initial_tip]
      type = BoxMarker
      bottom_left = '26 0 0'
      top_right = '28 1 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Contact]
  [v_notch]
    primary = bar_v
    secondary = v-entire
    model = coulomb
    formulation = penalty
    normalize_penalty = true
    friction_coefficient = 0.35
    penalty = 1e3
    tangential_tolerance = 0.005
    newmark_beta = ${beta}
    newmark_gamma = ${gamma}
  []
[]

# [Dampers]
#   [slip]
#     type = ContactSlipDamper
#     secondary = v-entire
#     primary = bar-v
#   []
# []

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
  [fx]
  []
  [fy]
  []
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=19&x<=27,1,0)'
    # []
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
    # [InitialCondition]
    #   type = ConstantIC
    #   value = 15e3
    #   block = 2
    # []
  []
  [vel_y]
  []
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [d_dist]
  []
  # [tip_dist]
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
  # [solid_x]
  #   type = ADDynamicStressDivergenceTensors
  #   variable = disp_x
  #   component = 0
  #   alpha = 0.11
  #   save_in = fx
  # []
  # [solid_y]
  #   type = ADDynamicStressDivergenceTensors
  #   variable = disp_y
  #   component = 1
  #   alpha = 0.11
  #   save_in = fy
  # []
  [inertia_x]
    type = InertialForce
    variable = disp_x
    density = reg_density
    block = 0
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    density = reg_density
    block = 0
    velocity = vel_y
    acceleration = accel_y
  []
  [inertia_x_putty]
    type = InertialForce
    variable = disp_x
    density = density_p
    block = 2
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y_putty]
    type = InertialForce
    variable = disp_y
    density = density_p
    block = 2
    velocity = vel_y
    acceleration = accel_y
  []
  [inertia_x_steel]
    type = InertialForce
    variable = disp_x
    density = density_s
    block = '1'
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y_steel]
    type = InertialForce
    variable = disp_y
    density = density_s
    block = '1'
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
  [accel_x] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    # type = TestNewmarkTI
    # first = false
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  []
  [vel_x] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    # type = TestNewmarkTI
    variable = vel_x
    acceleration = accel_x
    execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    # type = TestNewmarkTI
    # first = false
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    # type = TestNewmarkTI
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  []
  # [d_dist]
  #   type = ParsedAux
  #   variable = d_dist
  #   coupled_variables = d
  #   # expression = 'if(d > d_cr & y > 0, sqrt((x - 27)^2 + y^2), -1)'
  #   expression = 'if(d > d_cr & y > 0, x-27, -1)'
  #   use_xyzt = true
  #   constant_names = d_cr
  #   constant_expressions = 0.95
  # []
[]

[BCs]
  [fix_top_x]
    type = DirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
  [fix_top_y]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  []
  [fix_center_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'noncrack bar_center'
    value = 0
  []
  # [initial_vel]
  #   type = PresetVelocity
  #   variable = disp_x
  #   boundary = striker_bnd
  #   function = '15e3' #mm/s
  # []
  [pressue_x]
    type = ADPressure
    # component = 0
    variable = disp_x
    displacements = 'disp_x disp_y'
    # boundary = 'v-load'
    boundary = 'bar_left'
    function = p_func
  []
  [pressue_y]
    type = ADPressure
    # component = 1
    variable = disp_y
    displacements = 'disp_x disp_y'
    # boundary = 'v-load'
    boundary = 'bar_left'
    function = p_func
  []
  # [mix_x]
  #   type = ADFunctionNeumannBC
  #   variable = disp_x
  #   displacements = 'disp_x disp_y'
  #   boundary = 'v-load'
  #   function = t_func_x
  # []
  # [mix_y]
  #   type = ADFunctionNeumannBC
  #   variable = disp_y
  #   displacements = 'disp_x disp_y'
  #   boundary = 'v-load'
  #   function = t_func_y
  # []
[]

# [Controls]
#   [impact]
#     type = TimePeriod
#     enable_objects = 'BCs::initial_vel'
#     start_time = '0'
#     end_time = '5e-8'
#   []
# []

[Materials]
  # bego
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho} ${psic}'
    block = 0
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
    block = 0
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 -0.5 0.0 1e-6'
    block = 0
  []
  # [nodegradation] # test without d
  #   type = NoDegradation
  #   f_name = g 
  #   function = 1
  #   phase_field = d
  #   block = 0
  # []
  [reg_density]
    type = MaterialADConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
    block = 0
  []
  [strain]
    type = ADComputePlaneSmallStrain
    # type = ADComputeSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
    block = 0
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
    block = 0
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
    block = 0
  []

  # putty
  [elasticity_putty]
    type = ADComputeIsotropicElasticityTensor
    bulk_modulus = ${K_p}
    shear_modulus = ${G_p}
    block = 2
  []
  [density_putty]
    type = GenericConstantMaterial
    prop_names = 'density_p'
    prop_values = '${rho_p}'
    block = 2
  []
  [stress_putty]
    type = ADComputeLinearElasticStress
    block = 2
  []
  [strain_putty]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    block = 2
  []

  # steel for bar and striker
  [elasticity_steel]
    type = ADComputeIsotropicElasticityTensor
    bulk_modulus = ${K_s}
    shear_modulus = ${G_s}
    block = '1'
  []
  [density_steel]
    type = GenericConstantMaterial
    prop_names = 'density_s'
    prop_values = '${rho_s}'
    block = '1'
  []
  [stress_steel]
    type = ADComputeLinearElasticStress
    block = '1'
    output_properties = 'stress'
    outputs = exodus
  []
  [strain_steel]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    block = '1'
  []
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = v-entire
    outputs = 'pp exodus'
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = v-entire
    outputs = 'pp exodus'
  []
  # [disp_x]
  #   type = PointValue
  #   point = '0 8.493 0'
  #   variable = disp_x
  # []
  # [open_disp_y]
  #   type = PointValue
  #   point = '0 8.493 0'
  #   variable = disp_y
  # []
  [max_d]
    type = NodalExtremeValue
    variable = d
    value_type = max
    outputs = pp
  []
  [max_f_nu]
    type = ElementExtremeValue
    variable = f_nu_var
    value_type = max
    outputs = pp
  []
  # [Jint]
  #   type = PhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'left bottom right top' # ? need to define in mesh?
  # []
  # crack tip tracking
  # [tip_x]
  #   type = PDCrackTipTracker
  #   variable = d_dist
  #   component = 0
  #   initial_coord = 27
  #   outputs = tip
  #   execute_on = 'initial timestep_begin'
  # []
  # [tip_y]
  #   type = PDCrackTipTracker
  #   variable = d_dist
  #   component = 1
  #   initial_coord = 0
  #   outputs = tip
  #   execute_on = 'initial timestep_begin'
  # []
  # [tip_z]
  #   type = PDCrackTipTracker
  #   variable = d_dist
  #   component = 2
  #   initial_coord = 0
  #   outputs = tip
  #   execute_on = TIMESTEP_END
  # []
  # [dx]
  #   type = ChangeOverTimePostprocessor
  #   postprocessor = tip_x
  #   outputs = none
  # []
  # [dy]
  #   type = ChangeOverTimePostprocessor
  #   postprocessor = tip_y
  #   outputs = none
  # []
  # [dz]
  #   type = ChangeOverTimePostprocessor
  #   postprocessor = tip_z
  #   outputs = none
  # []
  # [dt]
  #   type = TimestepSize
  #   outputs = none
  # []
  # [tip_velocity]
  #   type = ParsedPostprocessor
  #   pp_names = 'dx dy dz dt'
  #   function = 'sqrt(dx^2 + dy^2 + dz^2)/dt'
  #   outputs = tip
  # []
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
  # solve_type = PJFNK
  # petsc_options = '-snes_converged_reason -ksp_converged_reason -pc_svd_monitor '
  #                 '-snes_linesearch_monitor'
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -mat_mffd_err'
  # petsc_options_value = 'lu       NONZERO               1e-15                   1e-5'
  automatic_scaling = true

  # dt = 5e-8 # 0.05 us
  dtmin = 5e-9
  [TimeStepper]
    type = FunctionDT
    function = 'if(t<8.5e-6, 5e-7, 5e-8)'
  []
  end_time = 300e-6
  line_search = 'basic'

  # restart
  # start_time = 80e-6
  # end_time = 120e-6
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # nl_rel_tol = 1e-4
  # nl_abs_tol = 1e-6
  # nl_max_its = 20

  fixed_point_max_its = 50
  # accept_on_max_fixed_point_iteration = false
  accept_on_max_fixed_point_iteration = true
  # fixed_point_rel_tol = 1e-6
  # fixed_point_abs_tol = 1e-8
  fixed_point_rel_tol = 1e-4
  fixed_point_abs_tol = 1e-6

  [TimeIntegrator]
    type = NewmarkBeta
    # type = CentralDifference
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 5e-7
  []
  print_linear_residuals = true
  # file_base = '../out/half_coh_p${p}_gc${Gc}_sigma_ts${sigma_ts}_l${l}_h${refine}/half_p${p}_gc${Gc}_sigma_ts${sigma_ts}_l${l}_h${refine}'
  file_base = '../out/half_coh_contact_part/half_coh_contact_part'
  # file_base = '../out/hht_half_test'
  interval = 1
  checkpoint = true
  [pp]
    type = CSV
    # file_base = '../gold/pp_half_coh_p${p}_gc${Gc}_sigma_ts${sigma_ts}_l${l}_h${refine}'
    file_base = '../out/half_coh_contact_part/half_coh_load_contact_part'
  []
  # [tip]
  #   type = CSV
  #   file_base = '../gold/tip_half_coh_p${p}_gc${Gc}_ts${sigma_ts}_cs${sigma_cs}_l${l}_d${delta}_h${refine}'
  # []
[]

# [Debug]
#   show_var_residual_norms = true
# []
