# 1D wave equation
# elasticity basic: see (modules/tensor_mechanics/test/tests/ad_elastic/finite_elastic.i)
# M*accel + K*disp = 0 which is equivalent to
# density*accel + Div Stress = 0
# The first term on the left is evaluated using the Inertial force kernel
# The last term on the left is evaluated using StressDivergenceTensors

# glass [L(m), T(s), M(kg)]
E = 0.0625e12 # 0.0625 TPa
G = 0.0262e12 # 0.0262 TPa
nu = '${fparse E/2/G - 1}'
K = '${fparse E*G/3/(3*G - E)}'
rho = 2230 # 2.2e-3 g/mm^3

Gc = 16 # 1.60 e-8 TPa.mm -> N/m
l = 0.02 # 0.0211 mm?

[MultiApps]
  [damage]
    type = TransientMultiApp
    input_files = damage.i
    cli_args = 'Gc=${Gc};l=${l}'
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
  [../]
  [to_pise_active]
    type = MultiAppCopyTransfer
    multi_app = damage
    direction = to_multiapp
    source_variable = psie_active
    variable = psie_active
  [../]
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 100
  xmin = 0.0
  xmax = 10.0
[]

[GlobalParams]
  displacements = 'disp_x'
[]

[Variables]
  [./disp_x]
  [../]
[]

[AuxVariables] 
  [./accel_x]
  [../]
  [./vel_x]
  [../]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [d]
  []
[]

[Kernels]
  [./solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    displacements = 'disp_x'
    component = 0
    # stiffness_damping_coefficient = 0.000025
  [../]
  [./inertia_x] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25 # Newmark time integration
    gamma = 0.5 # Newmark time integration
    eta = 0.0
  [../]
[]

[AuxKernels]
  [./accel_x] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_x] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  [../]
#   [./stress_xx]
#     type = RankTwoAux
#     rank_two_tensor = stress
#     variable = stress_xx
#     index_i = 0
#     index_j = 0
#   [../]
#   [./strain_xx]
#     type = RankTwoAux
#     rank_two_tensor = total_strain
#     variable = strain_xx
#     index_i = 0
#     index_j = 0
#   [../]
[]

[BCs]
  [./leftBC]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = left
    beta = 0.25
    function = 'if(t<=1, 0.01*sin(pi*t), 0)'
    velocity = vel_x
    acceleration = accel_x
  [../]
  [./rightBC]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = right
    beta = 0.25
    function = 'if(t<=1, 0.01*sin(pi*t), 0)'
    # function = '0.01*t'
    velocity = vel_x
    acceleration = accel_x
  [../]
[]

# [Materials]
#   [./elasticity]
#     type = ComputeIsotropicElasticityTensor
#     poissons_ratio = 0.3
#     youngs_modulus = 0.01 #Pa
#   [../]
#   [./strain]
#     type = ComputeSmallStrain
#     block = 0
#     displacement = 'disp_x'
#   [../]
#   [./stress]
#     type = ComputeLinearElasticStress
#     block = 0
#   [../]
#   [./density]
#     type = GenericConstantMaterial
#     block = 0
#     prop_names = density
#     prop_values = 2e-3 #kg/m3
#   [../]
# []

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'K G'
    prop_values = '${K} ${G}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
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
  [denstiy]
    type = GenericConstantMaterial
    block = 0
    prop_names = density
    prop_values = '${rho}'
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 3.0
  dt = 1e-2
  # l_tol = 1e-6
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-6
  # timestep_tolerance = 1e-6

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
  [./disp_x_rightBC]
    type = PointValue
    point = '10 0 0'
    variable = disp_x
  [../]
[]

[Outputs]
  exodus = true
  file_base = 'wave_1d'
  # [./csv]
  #   type = CSV 
  # [../]
[]