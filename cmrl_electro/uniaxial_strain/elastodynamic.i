rho = 8e-9
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
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = RankTwoAux
      rank_two_tensor = cauchy_stress
      index_i = 2
      index_j = 2
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

[Functions]
  [load_func]
    type = ADParsedFunction
    expression = 'if(t<t0, v0/2/t0*t^2, v0*t - 0.5*v0*t0)'
    symbol_names = 'v0 t0'
    symbol_values = '16.5e3 1e-6'
  []
[]

[BCs]
  [xdisp]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = 2
    function = load_func
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = 1
    value = 0
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '${rho}'
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1.9e5
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
  type = Transient
  solve_type = NEWTON
  start_time = 0
  end_time = 20e-6
  dt = 5e-7
  dtmin = 1e-8
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

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
    simulation_time_interval = 1e-6
    time_step_interval = 1
  []
  print_linear_residuals = false
  file_base = './out/kal_elastic'
  checkpoint = true
[]