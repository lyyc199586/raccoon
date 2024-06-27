# verify analytical solution from Freund's book
# see Belytschko 2003, Fig 21 and 22

# use geometry and material properties of PMMA dynamic (top half domain)

# sharp model, assign V

# PMMA, MPa, N, mm
E = 32e3 # 32 GPa
nu = 0.2
# rho = 2.54e-9 # Mg/mm^3
rho = 2.45e3
# rho = 2.45e2
Gc = 0.003
# sigma_ts = 3.08 # MPa
CR = 2.119 # mm/us
# Cd = 3.81 # mm/us
# Cs = 2333 m/s = 2.33 mm/us

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
# c1 = '${fparse (1+nu)*sqrt(Gc)/sqrt(2*pi*E)}'
# c2 = '${fparse (3-nu)/(1+nu)}'

# vel control
# V = 0
# V = ${fparse 0.4*CR}
# tp = ${fparse 20/Cd}
# tf = ${fparse 2.5*tp}
Tp = 20
Tc = 10
Tf = 60
# s0 = 1
u0 = 1.4e-3
# h = 1
refine = 3

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[Functions]
  [moving]
    type = ParsedFunction
    expression = 'x-tip'
    symbol_names = 'tip'
    symbol_values = 'tip'
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
    nx = 100
    ny = 20
    xmin = 0
    xmax = 100
    ymin = 0
    ymax = 20
  []
  [crack_region]
    input = gen
    type = ParsedSubdomainMeshGenerator
    block_id = 1
    combinatorial_geometry = 'abs(y)<2'
    block_name = small
  []
  [refine]
    input = crack_region
    type = RefineBlockGenerator
    block = 1
    refinement = ${refine}
  []
  [noncrack] # x in (50, 100), y = 0
    type = BoundingBoxNodeSetGenerator
    input = refine 
    bottom_left = '${fparse 50-0.001} -0.001 0'
    top_right = '${fparse 100+0.001} 0.001 0'
    new_boundary = noncrack
  []
  # construct_side_list_from_node_list=true
[]

[UserObjects]
  [moving_bnd]
    type = MovingNodeSetUserObject
    indicator = 'phi'
    criterion_type = ABOVE
    threshold = 0
    moving_boundary_name = noncrack
    execute_on = 'TIMESTEP_BEGIN'
    boundary = 'bottom'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  # [strain_zz]
  # []
[]

[AuxVariables]
  [phi]
  []
  [tip_var]
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
  [d]
  []
  # [x_coord] # x coord for nodes in noncrack
  # []
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
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  # []
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
  [phi]
    type = FunctionAux
    variable = phi
    function = moving
    execute_on = 'TIMESTEP_BEGIN'
  []
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
  [ytop]
    type = SinDirichletBC
    variable = disp_y
    boundary = top
    initial = 0
    final = '${u0}'
    duration = ${Tp}
  []
  # [top]
  #   type = ADPressure
  #   variable = disp_y
  #   boundary = top
  #   function = ${s0}
  #   factor = -1
  # []
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
    # type = ADComputePlaneSmallStrain
    # out_of_plane_strain = 'strain_zz'
    type = ADComputeSmallStrain
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
  [J]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right'
  []
  [DJ1]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right'
    density = density
  []
  [DJ2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    block = '0 1'
    density = density
  []
  [DJ]
    type = ParsedPostprocessor
    expression = 'DJ1+DJ2'
    pp_names = 'DJ1 DJ2'
  []
  [tip_V]
    type = ParsedPostprocessor
    expression = 'if(t>Tc, abs(CR*(1 - Gc*1.25/4*J)), 0)'
    pp_names = 'J'
    constant_names = 'CR Gc Tc'
    constant_expressions = '${CR} ${Gc} ${Tc}'
    use_t = true
  []
  [tip_adv] # assign V
    type = ParsedPostprocessor
    expression = 'if(t>Tc, tip_V*dt, 0)'
    constant_names = 'Tc'
    constant_expressions = '${Tc}'
    pp_names = 'dt tip_V'
    use_t = true
  []
  # [tip_adv] # Gc formula
  #   type = ParsedPostprocessor
  #   expression = 'if(Jint>Gc, 1, 0)'
  #   pp_names = 'Jint'
  #   constant_names = 'Gc'
  #   constant_expressions = '${Gc}'
  # []
  [tip_cum]
    type = CumulativeValuePostprocessor
    postprocessor = tip_adv
  []
  [tip]
    type = ParsedPostprocessor
    expression = '50 + tip_cum' # initial_tip + tip_cmp
    pp_names = 'tip_cum'
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
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
  end_time = ${Tf}

  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<=${Tp},0.5,0.148)'
  # []
  dt = 0.5
  # num_steps = 3

[]

[Outputs]
  [exodus]
    type = Exodus
  []
  file_base = './out/sharp_u0_${u0}_tc${Tc}_tp${Tp}_tf${Tf}/sharp'
  print_linear_residuals = false
  [csv]
    type = CSV
    file_base = './gold/sharp_u0_${u0}_tc${Tc}_tp${Tp}_tf${Tf}'
  []
[]