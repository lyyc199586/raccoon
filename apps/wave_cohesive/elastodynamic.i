# 1D wave equation
# elasticity basic: see (modules/tensor_mechanics/test/tests/ad_elastic/finite_elastic.i)
# M*accel + K*disp = 0 which is equivalent to
# density*accel + Div Stress = 0
# The first term on the left is evaluated using the Inertial force kernel
# The last term on the left is evaluated using StressDivergenceTensors

Gc = 22.2
# l = 0.35
l = 1.5
psic = 7.9
E = 1.9e5
nu = 0.3
rho = 8e-9 # [Mg/mm^3]
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

sigma_ts = 1158 # MPa
sigma_cs = 5840 # MPa
# sigma_cs = 10340
delta = 4

[MultiApps]
  [damage]
    type = TransientMultiApp
    input_files = damage.i
    # cli_args = 'Gc=${Gc};l=${l}'
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = damage
    direction = from_multiapp
    source_variable = d
    variable = d
  []
  [to_pise_active]
    type = MultiAppCopyTransfer
    multi_app = damage
    direction = to_multiapp
    source_variable = psie_active
    variable = psie_active
    # source_variable = 'psie_active ce'
    # variable = 'psie_active ce'
  []
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 2000
  ny = 1
  nz = 1
  xmin = 0.0
  xmax = 1000
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 1
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
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
  [d]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    displacements = 'disp_x'
    component = 0
    # stiffness_damping_coefficient = 0.000025
  []
  [inertia_x] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25 # Newmark time integration
    gamma = 0.5 # Newmark time integration
    eta = 0.0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    displacements = 'disp_y'
    component = 1
    # stiffness_damping_coefficient = 0.000025
  []
  [inertia_y] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25 # Newmark time integration
    gamma = 0.5 # Newmark time integration
    eta = 0.0
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_z
    displacements = 'disp_z'
    component = 2
    # stiffness_damping_coefficient = 0.000025
  []
  [inertia_z] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25 # Newmark time integration
    gamma = 0.5 # Newmark time integration
    eta = 0.0
  []
[]

[AuxKernels]
  [accel_x] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_x] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  []
  [accel_y] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_y] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = timestep_end
  []
  [accel_z] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_z] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = timestep_end
  []
[]

[Functions]
  [right_force_bc_func]
    type = ParsedFunction
    value = 'if(t<T, amp*sin(pi*t/T), 0)'
    vars = 'amp T'
    vals = '-574.3875 1e-4'
  []
  [left_force_bc_func]
    type = ParsedFunction
    value = 'if(t<T, amp*sin(pi*t/T), 0)'
    vars = 'amp T'
    vals = '-574.3875 1e-4'
  []
[]

[BCs]
  # [leftBC]
  #   # type = ADFunctionDirichletBC
  #   type = ADFunctionNeumannBC
  #   variable = disp_x
  #   boundary = left
  #   beta = 0.25
  #   # function = 'if(t<=1e-6, 1e-6/pi*cos(pi*1e6*t), -1e-6/pi)'
  #   function = 'if(t<=1e-4, -0.2*sin(1e4*pi*t), 0)'
  #   # function = '1e-6/pi*cos(pi*1e5*t)'
  #   # function = '-0.2*sin(pi*t)'
  #   velocity = vel_x
  #   acceleration = accel_x
  # []
  # [rightBC]
  #   # type = ADFunctionDirichletBC
  #   type = ADFunctionNeumannBC
  #   variable = disp_x
  #   boundary = right
  #   beta = 0.25
  #   # function = 'if(t<=1e-6, -1e-6/pi*cos(pi*1e6*t), 1e-6/pi)'
  #   # # function = '-1e-6/pi*cos(pi*1e5*t)'
  #   function = 'if(t<=1e-4, 0.2*sin(1e4*pi*t), 0)'
  #   # function = '0.2*sin(pi*t)'
  #   # function = '0.01*t'
  #   velocity = vel_x
  #   acceleration = accel_x
  # []
  [leftBC]
    type = ADPressure
    variable = disp_x
    component = 0
    boundary = left
    function = left_force_bc_func
    # velocity = vel_x
    # acceleration = accel_x
  []
  [rightBC]
    type = ADPressure
    variable = disp_x
    component = 0
    boundary = right
    function = right_force_bc_func
    # velocity = vel_x
    # acceleration = accel_x
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${psic}'
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 0'
  # []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    function = (1-d)^p/((1-d)^p+(Gc/psic*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta
    phase_field = d
    material_property_names = 'Gc psic xi c0 l '
    parameter_names = 'p a2 a3 eta '
    parameter_values = '2 -0.5 0 1e-6'
  []
  [strain]
    type = ADComputeSmallStrain
    # block = 0
    # displacements = 'disp_x'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'elastic_strain psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [denstiy]
    type = GenericConstantMaterial
    block = 0
    prop_names = density
    prop_values = '${rho}'
  []
  # [kumar_material]
  #   type = NucleationMicroForce
  #   normalization_constant = c0
  #   tensile_strength = '${sigma_ts}'
  #   compressive_strength = '${sigma_cs}'
  #   delta = '${delta}'
  #   external_driving_force_name = ce
  #   output_properties = 'ce'
  #   outputs = exodus
  # []
[]

[Executioner]
  type = Transient
  start_time = 0
  # end_time = 5e-6 # 5 us
  # dt = 5e-8       # 0.05 us
  end_time = 1.6e-4 # 1 ms
  dt = 1e-6       # 0.05 us

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  fixed_point_max_its = 100
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Postprocessors]
  [disp_x_rightBC]
    type = PointValue
    point = '1000 0 0'
    variable = disp_x
  []
  [vel_x_rightBC]
    type = PointValue
    point = '1000 0 0'
    variable = vel_x
  []
  [accel_x_rightBC]
    type = PointValue
    point = '1000 0 0'
    variable = accel_x
  []
  [stress_x_rightBC]
    type = PointValue
    point = '1000 0 0'
    variable = stress_00
  []
  [stress_x_middle]
    type = PointValue
    point = '500 0 0'
    variable = stress_00
  []
  [pf_d_right]
    type = PointValue
    point = '1000 0 0'
    variable = d
  []
  [pf_d_middle]
    type = PointValue
    point = '500 0 0'
    variable = d
  []
[]

[Outputs]
  exodus = true
  file_base = 'wave_c300_cohesive_3d'
  interval = 1
  [./csv]
    type = CSV 
  [../]
[]