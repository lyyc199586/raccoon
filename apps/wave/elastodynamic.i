# 1D wave equation
# elasticity basic: see (modules/tensor_mechanics/test/tests/ad_elastic/finite_elastic.i)
# M*accel + K*disp = 0 which is equivalent to
# density*accel + Div Stress = 0
# The first term on the left is evaluated using the Inertial force kernel
# The last term on the left is evaluated using StressDivergenceTensors

Gc = 22.2
# l = 0.35
l = 1
# psic = 7.9
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
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l}'
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
    # source_variable = psie_active
    # variable = psie_active
    source_variable = 'psie_active ce'
    variable = 'psie_active ce'
  []
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 2000
  xmin = 0.0
  xmax = 1000
[]

[GlobalParams]
  displacements = 'disp_x'
[]

[Variables]
  [disp_x]
  []
[]

[AuxVariables] 
  [accel_x]
  []
  [vel_x]
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
[]

[BCs]
  [leftBC]
    # type = ADFunctionDirichletBC
    type = ADFunctionNeumannBC
    variable = disp_x
    boundary = left
    beta = 0.25
    # function = 'if(t<=1e-4, 1e-4/pi*0.01*cos(pi*0.5e4*t) - 1e-4/pi, -1e-4/pi)'
    function = 'if(t<=1e-4, -0.2*sin(1e4*pi*t), 0)'
    # function = '1e-6/pi*cos(pi*1e5*t)'
    # function = '-0.2*sin(pi*t)'
    velocity = vel_x
    acceleration = accel_x
  []
  [rightBC]
    # type = ADFunctionDirichletBC
    type = ADFunctionNeumannBC
    variable = disp_x
    boundary = right
    beta = 0.25
    # function = 'if(t<=1e-4, -1e-4/pi*0.01*cos(pi*0.5e4*t) + 1e-4/pi, 1e-4/pi)'
    # function = '-1e-6/pi*cos(pi*1e5*t)'
    function = 'if(t<=1e-4, 0.2*sin(1e4*pi*t), 0)'
    # function = '0.2*sin(pi*t)'
    # function = '0.01*t'
    velocity = vel_x
    acceleration = accel_x
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 0'
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
  [kumar_material]
    type = NucleationMicroForce
    normalization_constant = c0
    tensile_strength = '${sigma_ts}'
    compressive_strength = '${sigma_cs}'
    delta = '${delta}'
    external_driving_force_name = ce
    output_properties = 'ce'
    outputs = exodus
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  # end_time = 5e-6 # 5 us
  # dt = 5e-8       # 0.05 us
  end_time = 2e-3 # 1 ms
  dt = 5e-6       # 0.05 us

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-8
  fixed_point_abs_tol = 1e-10
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
  file_base = 'wave_c300_kumar'
  interval = 1
  [./csv]
    type = CSV 
  [../]
[]