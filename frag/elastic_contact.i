# material properties (MPa, N, mm, Mg/mm^3)
## Al 
# E_a = 70e3
# nu_a = 0.35
# rho_a = 2.7e-9

## steel
E_a = 190e3 
nu_a = 0.3
rho_a = 8e-9

# bego
E_b = 6.16e3
nu_b = 0.2
rho_b = 1.995e-9

# hht parameters
hht_alpha = -0.25
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

# simulation settings
v0 = -2e4 # 10 m/s
t0 = 10e-6
Dt = 50e-6
tf = '${fparse t0 + Dt}'
gap = '${fparse -v0*t0}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = true
[]

[Mesh]
  [gen1]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 30
    xmin = -20
    xmax = 20
    ymin = -30
    ymax = 0
    boundary_name_prefix = bego
  []
  [gen2]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin = -5
    xmax = 5
    ymin = ${gap}
    ymax = '${fparse gap+10}'
    boundary_name_prefix = impactor
    boundary_id_offset = 4
  []
  [collect]
    type = MeshCollectionGenerator
    inputs = 'gen1 gen2'
  []
  [total_impactor_bnd]
    type = BoundingBoxNodeSetGenerator
    input = collect
    new_boundary = impactor_total
    bottom_left = '-5.1 ${fparse gap/2} -0.1'
    top_right = '5.1 ${fparse gap+10} 0.1'
  []
  [total_impactor_block]
    type = SubdomainBoundingBoxGenerator
    input = total_impactor_bnd
    block_id = 1
    block_name = impactor
    bottom_left = '-5.1 ${fparse gap/2} -0.1'
    top_right = '5.1 ${fparse gap+10} 0.1'
  []
  patch_update_strategy = iteration
  coord_type = XYZ
  construct_side_list_from_node_list=true
[]

[Contact]
  [impacting]
    primary = impactor_bottom
    secondary = bego_top
    model = frictionless
    formulation = penalty
    penalty = 1e10
    normalize_penalty = true
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
  [penetration]
  []
  [fx]
  []
  [fy]
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
  # impactor
  [inertia_x_a]
    type = ADInertialForce
    variable = disp_x
    density = rho_a
    velocity = vel_x
    acceleration = accel_x
    block = 1
  []
  [inertia_y_a]
    type = ADInertialForce
    variable = disp_y
    density = rho_a
    velocity = vel_y
    acceleration = accel_y
    block = 1
  []
  # bego
  [inertia_x_b]
    type = ADInertialForce
    variable = disp_x
    density = rho_b
    velocity = vel_x
    acceleration = accel_x
    block = 0
  []
  [inertia_y_b]
    type = ADInertialForce
    variable = disp_y
    density = rho_b
    velocity = vel_y
    acceleration = accel_y
    block = 0
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
  [penetration]
    type = PenetrationAux
    variable = penetration
    boundary = impactor_bottom
    paired_boundary = bego_top
  []
[]

[BCs]
  [initial_velocity]
    type = PresetVelocity
    variable = disp_y
    boundary = impactor_total
    velocity = ${v0}
    control_tags = control_bc
  []
  [fix_bottom]
    type = ADDirichletBC
    value = 0
    variable = disp_y
    boundary = bego_bottom
  []
[]

[Controls]
  [control_bc]
    type = TimePeriod
    disable_objects = 'BCs::initial_velocity'
    start_time = ${t0}
  []
[]

[Materials]
  # Al
  [al_density]
    type = ADGenericConstantMaterial
    prop_names = 'rho_a'
    prop_values = '${rho_a}'
    block = 1
  []
  [al_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E_a}
    poissons_ratio = ${nu_a}
    block = 1
  []
  # bego
  [bego_density]
    type = ADGenericConstantMaterial
    prop_names = 'rho_b'
    prop_values = '${rho_b}'
    block = 0
  []
  [bego_elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E_b}
    poissons_ratio = ${nu_b}
    block = 0
  []
  #
  [strain]
    type = ADComputeSmallStrain
  []
  [stress]
    type = ADComputeLinearElasticStress
    output_properties = stress
    outputs = 'exodus'
  []
[]

[Postprocessors]
  [avg_vel_impactor]
    type = SideAverageValue
    variable = vel_y
    boundary = impactor_total
  []
  [avg_disp_y_impactor]
    type = SideAverageValue
    variable = disp_y
    boundary = impactor_bottom
  []
  [max_vel_bego]
    type = NodalExtremeValue
    variable = vel_y
    value_type = min
    block = 0
  []
  [max_disp_bego]
    type = NodalExtremeValue
    variable = disp_y
    value_type = min
    block = 0
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre     boomeramg                 '
  automatic_scaling = true

  line_search = l2

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  end_time = ${tf}

  [TimeStepper]
    type = FunctionDT
    function = 'if(t<${t0}, 1e-6, 1e-7)'
  []


  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
    minimum_time_interval = 1e-7
  []
  print_linear_residuals = false
  file_base = './out/elastic_contact_steel_fix_bottom_v0${v0}'
  checkpoint = true
  [csv]
    file_base = './gold/elastic_contact_steel_fix_bottom_v0${v0}'
    type = CSV
  []
[]