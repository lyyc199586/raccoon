rho = 2450
hht_alpha = -0.00
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/branch.msh'
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
    # initial_condition = 0
  []
  [accel_y]
  []
  [vel_y]
    # initial_condition = 0
  []
  [accel_z]
  []
  [vel_z]
    # initial_condition = 0
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = RankTwoAux
      rank_two_tensor = cauchy_stress
      index_i = 1
      index_j = 1
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[Kernels]
  [solid_x]
    type = TotalLagrangianStressDivergence
    variable = disp_x
    displacements = 'disp_x disp_y disp_z'
    component = 0
  []
  [inertia_x] # M*accel + eta*M*vel
    type = ADInertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    density = density
    # use_displaced_mesh = true
  []
  [solid_y]
    type = TotalLagrangianStressDivergence
    variable = disp_y
    displacements = 'disp_x disp_y disp_z'
    component = 1
  []
  [inertia_y] # M*accel + eta*M*vel
    type = ADInertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    density = density
    # use_displaced_mesh = true
  []
  [solid_z]
    type = TotalLagrangianStressDivergence
    variable = disp_z
    displacements = 'disp_x disp_y disp_z'
    component = 2
  []
  [inertia_z] # M*accel + eta*M*vel
    type = ADInertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    density = density
    # use_displaced_mesh = true
  []
[]

[AuxKernels]
  [accel_x] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    # execute_on = timestep_end
  []
  [vel_x] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    # execute_on = timestep_end
  []
  [accel_y] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    # execute_on = timestep_end
  []
  [vel_y] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    # execute_on = timestep_end
  []
  [accel_z] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    # execute_on = timestep_end
  []
  [vel_z] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    # execute_on = timestep_end
  []
[]

[BCs]
  [top]
    type = ADNeumannBC
    boundary = 'top'
    variable = disp_y
    value = 1
  []
  [bottom]
    type = ADNeumannBC
    boundary = 'bottom'
    variable = disp_y
    value = -1
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
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '${rho}'
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 32e3
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
  # [Predictor]
  #   type = SimplePredictor
  #   scale = 1
  # []
  type = Transient
  solve_type = NEWTON
  # start_time = 1e-8
  # end_time = 2.995940246582039E-004
  start_time = 0
  # end_time = 70
  end_time = 10
  dt = 0.25
  # dtmin = 5e-9
  # dt = 1e-6
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # l_tol = 1e-4
  # r_tol = 1e-6
  # nl_max_its = 20
  nl_max_its = 500
  l_max_its = 500
  line_search = None
  [TimeIntegrator]
    type = NewmarkBeta
    inactive_tsteps = 1
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    simulation_time_interval = 1.0
    # file_base = './out/vtk/moose'
    time_step_interval = 4
  []
  print_linear_residuals = false
  file_base = './out/branch_elastic'
  checkpoint = true
[]