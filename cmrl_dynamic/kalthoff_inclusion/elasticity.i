rho = 8e-9
hht_alpha = 0.00
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'
E = 1.9e5
nu = 0.3
Gc = 22.2
l = 0.6
factor = 0.05
filebase = 'frac_czm_${factor}Gc'

##
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'K=${K};G=${G};Gc=${Gc};l=${l};'
    # cli_args = 'K=${K};G=${G};Gc=${Gc};l=${l};factor=${factor}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_fracture]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    source_variable = d
    variable = d
  []
  [to_fracture]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    source_variable = 'disp_x disp_y psie_active'
    variable = 'disp_x disp_y psie_active'
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/kalthoff_inclusion.msh'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = fmg
    split_interface = true
    block_pairs = '1 2'
  []
[]

[Physics]

  [SolidMechanics]

    [CohesiveZone]
      [czm_12]
        boundary = 'Vol_matrix_Vol_fiber'
        strain = SMALL
        # strain = FINITE
        generate_output = 'normal_traction tangent_traction normal_jump tangent_jump'
      []
    []
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  alpha = ${hht_alpha}
  beta = ${beta}
  gamma = ${gamma}
  # large_kinematics = true
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
  [d]
  []
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
  [fx]
  []
  [fy]
  []
  [fz]
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_xy]
    order = CONSTANT
    family = MONOMIAL
  []
  [vonmises]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    displacements = 'disp_x disp_y disp_z'
    component = 0
    save_in = fx
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
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    displacements = 'disp_x disp_y disp_z'
    component = 1
    save_in = fy
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
    type = ADDynamicStressDivergenceTensors
    variable = disp_z
    displacements = 'disp_x disp_y disp_z'
    component = 2
    save_in = fz
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
  [stress_xx]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  []
  [stress_yy]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  []
  [stress_zz]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  []
  [stress_xy]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  []
  [vonmises]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = vonmises
    scalar_type = VonMisesStress
    execute_on = timestep_end
  []
[]

[Functions]
  [load_func]
    type = ADParsedFunction
    expression = 'if(t<t0, v0/2/t0*t^2, v0*t - 0.5*v0*t0)'
    symbol_names = 'v0 t0'
    symbol_values = '16.5e3 1e-6'
  []
  # [load_func]
  #   type = PiecewiseLinear
  #   x = '0.00 2.50E-07 5.00E-07 7.50E-07 1.00E-06 3.00E-05 9.00e-5'
  #   y = '0.00 5.20E-04 2.10E-03 4.60E-03 8.20E-03 4.90E-01 1.5'
  # []
[]

[BCs]
  [xdisp]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = 'load'
    function = load_func
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  []
[]

[Materials]
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = '${rho}'
  []
  [czm]
    type = BiLinearMixedModeTraction
    boundary = 'Vol_matrix_Vol_fiber'
    penalty_stiffness = ${E}
    GI_c = ${fparse Gc*factor}
    GII_c = ${fparse Gc*factor}
    normal_strength = 1733
    shear_strength = 1400
    displacements = 'disp_x disp_y disp_z'
    eta = 2.2
    viscosity = 1e-3
  []
  [bulk_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'K'
    subdomain_to_prop_value = '1 ${K}
                               2 ${fparse K}'
  []
  [shear_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'G'
    subdomain_to_prop_value = '1 ${G}
                               2 ${fparse G}'
  []
  [Gc]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'Gc'
    subdomain_to_prop_value = '1 ${Gc}
                               2 ${Gc}'
  []
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'l'
    prop_values = '${l}'
  []
  [small_deformation_elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    output_properties = 'psie_active'
    outputs = 'exodus'
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = small_deformation_elasticity
    output_properties = 'stress'
    # outputs = 'exodus'
  []
  [strain]
    type = ADComputeSmallStrain
  []
  [degradation]
    type = RationalDegradationFunction
    phase_field = d
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd^2'
    phase_field = d
  []
[]

[Postprocessors]
  [Fx]
    type = NodalSum
    variable = fx
    boundary = load
  []
  [disp_x]
    type = SideAverageValue
    boundary = load
    variable = disp_x
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
    value_type = max
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0
  # end_time = 85e-6
  end_time = 60e-6
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
    min_simulation_time_interval = 1e-6
    file_base = './out/${filebase}'
  []
  [csv]
    file_base = './gold/${filebase}'
    type = CSV
  []
  print_linear_residuals = false
  checkpoint = true
[]