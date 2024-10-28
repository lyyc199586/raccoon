rho = 1e-6
hht_alpha = -0.00
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/bar.msh'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  alpha = ${hht_alpha}
  beta = ${beta}
  gamma = ${gamma}
  large_kinematics = true
  use_displaced_mesh = false
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables] 
  [accel_x]
  []
  [vel_x]
  []
  [accel_y]
  []
  [vel_y]
  []
  [accel_z]
  []
  [vel_z]
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = RankTwoAux
      rank_two_tensor = cauchy_stress
      index_i = 0
      index_j = 0
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[Kernels]
  [solid_x]
    type = TotalLagrangianStressDivergence
    variable = disp_x
    displacements = 'disp_x'
    component = 0
  []
  [inertia_x] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    density = density
  []
  [solid_y]
    type = TotalLagrangianStressDivergence
    variable = disp_y
    displacements = 'disp_x disp_y disp_z'
    component = 1
  []
  [inertia_y] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    density = density
  []
  [solid_z]
    type = TotalLagrangianStressDivergence
    variable = disp_z
    displacements = 'disp_x disp_y disp_z'
    component = 2
  []
  [inertia_z] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    density = density
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
  [accel_y] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  []
  [vel_y] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  []
  [accel_z] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    execute_on = timestep_end
  []
  [vel_z] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    execute_on = timestep_end
  []
[]

[Functions]
  [load]
    type = ADParsedFunction
    expression = '0.4*(1-exp(-2.3983e5*t))'
  []
[]

[BCs]
  [left_x]
    type = ADFunctionDirichletBC
    boundary = '1'
    variable = disp_x
    function = load
    preset = true
  []
  # [right_x]
  #   type = ADDirichletBC
  #   boundary = '2'
  #   value = 0
  #   variable = disp_x
  # []
  # [fix_y]
  #   type = ADDirichletBC
  #   boundary = 1
  #   value = 0
  #   variable = disp_y
  # []
  # [fix_z]
  #   type = ADDirichletBC
  #   boundary = 1
  #   value = 0
  #   variable = disp_z
  # []
[]

[Materials]
  [bulk]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '${rho}'
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 30000
    poissons_ratio = 0.2
  []
  [stress]
    type = ComputeLagrangianLinearElasticStress
    # outputs = 'vtk'
  []
  [strain]
    type = ComputeLagrangianStrain 
  []
[]

# [Preconditioning]
#   [smp]
#     # this block is part of what is being tested, see "tests" file
#     type = SMP
#     full = true
#   []
# []

[Executioner]
  [Predictor]
    type = SimplePredictor
    scale = 1
  []
  type = Transient
  solve_type = NEWTON
  start_time = 1e-8
  end_time = 2.995940246582039E-004
  dtmin = 5e-9
  # dt = 1e-6
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'hypre boomeramg'
  # automatic_scaling = true
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # nl_max_its = 20
  nl_max_its = 200
  l_max_its = 500
  line_search = None
  [TimeIntegrator]
    type = NewmarkBeta
    # inactive_tsteps = 1
  []
  # auto_preconditioning = false
  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<1e-5, 1e-7, 1e-6)'
  # []
  [TimeStepper]
    type = TimeSequenceStepper
    time_sequence = '
    1.000000000000000E-008
    2.500000000000000E-008
    4.750000000000001E-008
    8.125000000000002E-008
    1.318750000000000E-007
    2.078125000000000E-007
    3.217187500000001E-007
    4.925781250000001E-007
    7.488671875000002E-007
    1.133300781250000E-006
    1.709951171875000E-006
    2.574926757812501E-006
    3.574926757812501E-006
    4.574926757812501E-006
    5.574926757812500E-006
    6.574926757812500E-006
    7.574926757812500E-006
    8.574926757812500E-006
    9.574926757812500E-006
    1.000000000000000E-005
    1.063760986328125E-005
    1.159402465820313E-005
    1.259402465820313E-005
    1.359402465820313E-005
    1.459402465820313E-005
    1.559402465820313E-005
    1.659402465820313E-005
    1.759402465820313E-005
    1.859402465820313E-005
    1.959402465820313E-005
    2.059402465820313E-005
    2.159402465820313E-005
    2.259402465820313E-005
    2.359402465820313E-005
    2.459402465820313E-005
    2.559402465820313E-005
    2.659402465820314E-005
    2.759402465820314E-005
    2.859402465820314E-005
    2.959402465820314E-005
    3.059402465820314E-005
    3.159402465820314E-005
    3.259402465820313E-005
    3.359402465820313E-005
    3.459402465820313E-005
    3.559402465820312E-005
    3.659402465820312E-005
    3.759402465820312E-005
    3.859402465820312E-005
    3.959402465820311E-005
    4.059402465820311E-005
    4.159402465820311E-005
    4.259402465820310E-005
    4.359402465820310E-005
    4.459402465820310E-005
    4.559402465820310E-005
    4.659402465820309E-005
    4.759402465820309E-005
    4.859402465820309E-005
    4.959402465820308E-005
    5.059402465820308E-005
    5.159402465820308E-005
    5.259402465820308E-005
    5.359402465820307E-005
    5.459402465820307E-005
    5.559402465820307E-005
    5.659402465820307E-005
    5.759402465820306E-005
    5.859402465820306E-005
    5.959402465820306E-005
    6.059402465820305E-005
    6.159402465820306E-005
    6.259402465820306E-005
    6.359402465820305E-005
    6.459402465820305E-005
    6.559402465820305E-005
    6.659402465820304E-005
    6.759402465820304E-005
    6.859402465820304E-005
    6.959402465820304E-005
    7.059402465820303E-005
    7.159402465820303E-005
    7.259402465820303E-005
    7.359402465820302E-005
    7.459402465820302E-005
    7.559402465820302E-005
    7.659402465820302E-005
    7.759402465820301E-005
    7.859402465820301E-005
    7.959402465820301E-005
    8.059402465820300E-005
    8.159402465820300E-005
    8.259402465820300E-005
    8.359402465820300E-005
    8.459402465820299E-005
    8.559402465820299E-005
    8.659402465820299E-005
    8.759402465820299E-005
    8.859402465820298E-005
    8.959402465820298E-005
    9.059402465820298E-005
    9.159402465820297E-005
    9.259402465820297E-005
    9.359402465820297E-005
    9.459402465820297E-005
    9.559402465820296E-005
    9.659402465820296E-005
    9.759402465820296E-005
    9.859402465820295E-005
    9.959402465820295E-005
    1.005940246582029E-004
    1.015940246582029E-004
    1.025940246582029E-004
    1.035940246582029E-004
    1.045940246582029E-004
    1.055940246582029E-004
    1.065940246582029E-004
    1.075940246582029E-004
    1.085940246582029E-004
    1.095940246582029E-004
    1.105940246582029E-004
    1.115940246582029E-004
    1.125940246582029E-004
    1.135940246582029E-004
    1.145940246582029E-004
    1.155940246582029E-004
    1.165940246582029E-004
    1.175940246582029E-004
    1.185940246582029E-004
    1.195940246582029E-004
    1.205940246582029E-004
    1.215940246582029E-004
    1.225940246582029E-004
    1.235940246582029E-004
    1.245940246582029E-004
    1.255940246582029E-004
    1.265940246582029E-004
    1.275940246582029E-004
    1.285940246582029E-004
    1.295940246582029E-004
    1.305940246582029E-004
    1.315940246582029E-004
    1.325940246582029E-004
    1.335940246582029E-004
    1.345940246582029E-004
    1.355940246582029E-004
    1.365940246582029E-004
    1.375940246582029E-004
    1.385940246582029E-004
    1.395940246582029E-004
    1.405940246582029E-004
    1.415940246582028E-004
    1.425940246582028E-004
    1.435940246582028E-004
    1.445940246582028E-004
    1.455940246582028E-004
    1.465940246582028E-004
    1.475940246582028E-004
    1.485940246582028E-004
    1.495940246582028E-004
    1.505940246582028E-004
    1.515940246582028E-004
    1.525940246582028E-004
    1.535940246582028E-004
    1.545940246582028E-004
    1.555940246582028E-004
    1.565940246582028E-004
    1.575940246582028E-004
    1.585940246582028E-004
    1.595940246582028E-004
    1.605940246582028E-004
    1.615940246582028E-004
    1.625940246582028E-004
    1.635940246582028E-004
    1.645940246582028E-004
    1.655940246582028E-004
    1.665940246582028E-004
    1.675940246582028E-004
    1.685940246582028E-004
    1.695940246582028E-004
    1.705940246582028E-004
    1.715940246582028E-004
    1.725940246582028E-004
    1.735940246582028E-004
    1.745940246582028E-004
    1.755940246582028E-004
    1.765940246582027E-004
    1.775940246582027E-004
    1.785940246582027E-004
    1.795940246582027E-004
    1.805940246582027E-004
    1.815940246582027E-004
    1.825940246582027E-004
    1.835940246582027E-004
    1.845940246582027E-004
    1.855940246582027E-004
    1.865940246582027E-004
    1.875940246582027E-004
    1.885940246582027E-004
    1.895940246582027E-004
    1.905940246582027E-004
    1.915940246582027E-004
    1.925940246582027E-004
    1.935940246582027E-004
    1.945940246582027E-004
    1.955940246582027E-004
    1.965940246582027E-004
    1.975940246582027E-004
    1.985940246582027E-004
    1.995940246582027E-004
    2.005940246582027E-004
    2.015940246582027E-004
    2.025940246582027E-004
    2.035940246582027E-004
    2.045940246582027E-004
    2.055940246582027E-004
    2.065940246582027E-004
    2.075940246582027E-004
    2.085940246582027E-004
    2.095940246582027E-004
    2.105940246582027E-004
    2.115940246582027E-004
    2.125940246582026E-004
    2.135940246582026E-004
    2.145940246582026E-004
    2.155940246582026E-004
    2.165940246582026E-004
    2.175940246582026E-004
    2.185940246582026E-004
    2.195940246582026E-004
    2.205940246582026E-004
    2.215940246582026E-004
    2.225940246582026E-004
    2.235940246582026E-004
    2.245940246582026E-004
    2.255940246582026E-004
    2.265940246582026E-004
    2.275940246582026E-004
    2.285940246582026E-004
    2.295940246582026E-004
    2.305940246582026E-004
    2.315940246582026E-004
    2.325940246582026E-004
    2.335940246582026E-004
    2.345940246582026E-004
    2.355940246582026E-004
    2.365940246582026E-004
    2.375940246582026E-004
    2.385940246582026E-004
    2.395940246582026E-004
    2.405940246582026E-004
    2.415940246582026E-004
    2.425940246582026E-004
    2.435940246582026E-004
    2.445940246582026E-004
    2.455940246582026E-004
    2.465940246582026E-004
    2.475940246582026E-004
    2.485940246582027E-004
    2.495940246582027E-004
    2.505940246582027E-004
    2.515940246582027E-004
    2.525940246582028E-004
    2.535940246582028E-004
    2.545940246582028E-004
    2.555940246582028E-004
    2.565940246582029E-004
    2.575940246582029E-004
    2.585940246582029E-004
    2.595940246582029E-004
    2.605940246582029E-004
    2.615940246582030E-004
    2.625940246582030E-004
    2.635940246582030E-004
    2.645940246582030E-004
    2.655940246582031E-004
    2.665940246582031E-004
    2.675940246582031E-004
    2.685940246582031E-004
    2.695940246582032E-004
    2.705940246582032E-004
    2.715940246582032E-004
    2.725940246582032E-004
    2.735940246582033E-004
    2.745940246582033E-004
    2.755940246582033E-004
    2.765940246582033E-004
    2.775940246582034E-004
    2.785940246582034E-004
    2.795940246582034E-004
    2.805940246582034E-004
    2.815940246582035E-004
    2.825940246582035E-004
    2.835940246582035E-004
    2.845940246582035E-004
    2.855940246582036E-004
    2.865940246582036E-004
    2.875940246582036E-004
    2.885940246582036E-004
    2.895940246582037E-004
    2.905940246582037E-004
    2.915940246582037E-004
    2.925940246582037E-004
    2.935940246582038E-004
    2.945940246582038E-004
    2.955940246582038E-004
    2.965940246582038E-004
    2.975940246582038E-004
    2.985940246582039E-004
    2.995940246582039E-004  
    '
  []
[]

[Outputs]
  [vtk]
    type = Exodus
    # type = VTK
    simulation_time_interval = 1e-6
    # file_base = './out/vtk/moose'
    # time_step_interval = 1
  []
  print_linear_residuals = false
  file_base = './out/wave'
  checkpoint = true
[]