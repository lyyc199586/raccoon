# material params,
rho_epoxy = 1.3
rho_pzt = 2.6
K_epoxy = 2.17e6
G_epoxy = 1e6
K_pzt = 115e6
G_pzt = 4.5e6
l = 0.02
Gc_epoxy = 165e-3
Gc_pzt = 400e-3

# hht params
hht_alpha = -0.0
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'K_pzt=${K_pzt};K_epoxy=${K_epoxy};G_pzt=${G_pzt};;G_epoxy=${G_epoxy};Gc_pzt=${Gc_pzt};;Gc_epoxy=${Gc_epoxy};l=${l};'
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
    file = './mesh/compositeRVE.msh'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  alpha = ${hht_alpha}
  beta = ${beta}
  gamma = ${gamma}
  # large_kinematics = true
  # use_displaced_mesh = false
  # use_displaced_mesh = true
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
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoAux
      rank_two_tensor = stress
      index_i = 0
      index_j = 0
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoAux
      rank_two_tensor = stress
      index_i = 1
      index_j = 1
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoAux
      rank_two_tensor = stress
      index_i = 2
      index_j = 2
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [fx]
  []
  [fy]
  []
  [fz]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
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
    type = ADStressDivergenceTensors
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
    type = ADStressDivergenceTensors
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
  [load_func]
    type = PiecewiseLinear
    x = '0.00 1.00E-05 4.00E-05 1.60E-04 6.30E-04 0.1'
    y = '0.00 1.024E-05 2.952E-05 4.696E-05 4.800E-05 4.800E-05'
  []
  # [load_func]
  #   type = ADParsedFunction
  #   expression = 't*0.0002'
  # []
[]

[BCs]
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = '3'
    value = 0
  []
  [ytop]
    type = ADFunctionDirichletBC
    boundary = '2'
    variable = disp_y
    function = load_func
  []
  [fix_x]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = '4 5'
  []
  # [fix_d]
  #   type = ADDirichletBC
  #   variable = d
  #   boundary = '2 3 4 5'
  #   value = 0
  # []
[]

[Materials]
  [density]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'density'
    subdomain_to_prop_value = '1 ${rho_epoxy}
                               2 ${rho_pzt}'
  []
  [bulk_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'K'
    subdomain_to_prop_value = '1 ${K_epoxy}
                               2 ${K_pzt}'
  []
  [shear_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'G'
    subdomain_to_prop_value = '1 ${G_epoxy}
                               2 ${G_pzt}'
  []
  [Gc]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'Gc'
    subdomain_to_prop_value = '1 ${Gc_epoxy}
                               2 ${Gc_pzt}'
  []
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'l'
    prop_values = '${l}'
  []
  [cnh]
    type = CNHIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie psie_active'
    outputs = 'exodus'
  []
  # [small_deformation_elasticity]
  #   type = SmallDeformationIsotropicElasticity
  #   bulk_modulus = K
  #   shear_modulus = G
  #   phase_field = d
  #   degradation_function = g
  #   decomposition = NONE
  # []
  [stress]
    type = ComputeLargeDeformationStress
    elasticity_model = cnh
  []
  [defgrad]
    type = ComputeDeformationGradient
  []
  # [stress]
  #   type = ComputeSmallDeformationStress
  #   elasticity_model = small_deformation_elasticity
  #   output_properties = 'stress'
  # []
  # [strain]
  #   type = ADComputeSmallStrain
  # []
  # damage
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
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0
  end_time = 1e-4
  dtmin = 1e-15
  dtmax = 1e-3
  dt = 1e-7
  # [TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 1e-8
  #   optimal_iterations = 50
  #   iteration_window = 10
  #   growth_factor = 5
  # []
  # petsc_options_iname = '-pc_type -snes_type   -pc_factor_shift_type -pc_factor_shift_amount'
  # petsc_options_value = 'lu       vinewtonrsls NONZERO               1e-10'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # line_search = None

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  [TimeIntegrator]
    type = NewmarkBeta
    inactive_tsteps = 1
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    # min_simulation_time_interval = 1e-3
    # simulation_time_interval = 1e-2
    time_step_interval = 10
  []
  # simulation_time_interval = 1e-3
  # print_linear_residuals = false
  file_base = './out/fracture'
  # checkpoint = true
[]

# [Debug]
#   show_material_props = true
# []