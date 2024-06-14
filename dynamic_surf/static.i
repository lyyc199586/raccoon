# sharp model, assign V

# PMMA, MPa, N, mm
material = pmma
E = 32e3 # 32 GPa
nu = 0.2
# rho = 2.54e-9 # Mg/mm^3
rho = 2.45e3
# rho = 2.45e2
Gc = 0.003
# sigma_ts = 3.08 # MPa

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
c1 = '${fparse (1+nu)*sqrt(Gc)/sqrt(2*pi*E)}'
c2 = '${fparse (3-nu)/(1+nu)}'

# surfing 
V = 1
t_lag = 20
# tc = 36
tf = 50

# shape and scale
a = 10 # crack length
h = 1
length = '${fparse 6*a}'
width = '${fparse a}' # half width
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
    ymin = 0
    ymax = ${a}
  []
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
  [noncrack] # x in (a, 6a), y = 0
    type = BoundingBoxNodeSetGenerator
    input = refine 
    bottom_left = '${fparse a-0.001} -0.001 0'
    top_right = '${fparse 6*a+0.001} 0.001 0'
    new_boundary = noncrack
  []
  construct_side_list_from_node_list=true
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
  [d]
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
  # [phi]
  #   type = FunctionAux
  #   variable = phi
  #   function = moving
  #   execute_on = 'TIMESTEP_BEGIN'
  # []
  # [tip_var]
  #   type = FunctionAux
  #   variable = tip_var
  #   function = tip_circ
  #   execute_on = 'TIMESTEP_BEGIN'
  # []
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
  # [x_coord]
  #   type = ParsedAux
  #   variable = x_coord 
  #   expression = 'x'
  #   use_xyzt = true
  #   boundary = noncrack
  # []
[]

[BCs]
  [noncrack]
    type = ADDirichletBC
    variable = disp_y
    boundary = noncrack
    value = 0
  []
  [top_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = bc_func
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
    prop_names = 'E K G lambda Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${rho}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [nodeg]
    type = NoDegradation
    property_name = g 
    phase_field = d
    expression = 1
  []
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
    decomposition = NONE
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
  [dt]
    type = TimestepSize
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right'
  []
  [DJint]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right'
    density = density
  []
  [DJint_2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    block = '0 1'
  []
  # [tip_adv] # assign V
  #   type = ParsedPostprocessor
  #   # expression = 'if(t>Tc, V*dt, 0)'
  #   expression = 'if(t<Tc, 0, if(t<=Tc+4, 0.25*V*(t - Tc)*dt, V*dt))' # linear ramp
  #   # expression = 'if(t<Tc, 0, if(t<=Tc+4, V*dt*sin(pi*(t - Tc)/8), V*dt))' # sine ramp
  #   constant_names = 'Tc V pi'
  #   constant_expressions = '${tc} ${V} 3.1415926'
  #   pp_names = 'dt'
  #   use_t = true
  # []
  # [tip_adv] # Gc formula
  #   type = ParsedPostprocessor
  #   expression = 'if(Jint>Gc, 1, 0)'
  #   pp_names = 'Jint'
  #   constant_names = 'Gc'
  #   constant_expressions = '${Gc}'
  # []
  # [tip_cum]
  #   type = CumulativeValuePostprocessor
  #   postprocessor = tip_adv
  # []
  # [tip]
  #   type = ParsedPostprocessor
  #   expression = '${a} + tip_cum' # initial_tip + tip_cmp
  #   pp_names = 'tip_cum'
  #   execute_on = 'INITIAL TIMESTEP_BEGIN'
  # []
  # [tip_h]
  #   type = SideExtremeValue
  #   boundary = noncrack
  #   value_type = min
  #   variable = x_coord
  # []
  # [tip_adv_h]
  #   type = ChangeOverTimePostprocessor
  #   postprocessor = tip_h
  # []
  [top_react]
    type = NodalSum
    variable = f_y
    boundary = top
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
    boundary = 'top'
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
  start_time = 0
  end_time = ${tf}
  dt = 0.5

  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<=${tc}-1,0.5,0.05)'
  # []
  # num_steps = 3

[]

[Outputs]
  [exodus]
    type = Exodus
    # min_simulation_time_interval = 0.25
    # time_step_interval = 10
  []
  file_base = './out/${material}_static_rho${rho}/${material}_sharp'
  print_linear_residuals = false
  [csv]
    type = CSV
    file_base = './gold/${material}_static_rho${rho}'
  []
[]