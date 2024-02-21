# crack from pressurized hole

# # BegoStone mat prop (MPa, N, mm)
# E = 6.26e3
# nu = 0.2
# Gc = 3.656e-2
# sigma_ts = 10
# # sigma_cs = 37.4
# l = 0.5
# r = 10
# rho = 1.995e-9

## Rudy's paper Section 5.7
E = 210e3
rho = 7.85e-9
nu = 0.3
sigma_ts = 1e3
Gc = 20
l = 0.5
r = 10

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
psic = '${fparse sigma_ts^2/2/E}'

T0 = 100e-6
p0 = 400
seed = 3

## hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'


[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[Transfers]
  [from_patches]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = patches
    variable = 'psic'
    source_variable = 'psic'
    execute_on = 'INITIAL'
  []
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = 'psie_active disp_x disp_y psic'
    source_variable = 'psie_active disp_x disp_y psic'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};'
    execute_on = TIMESTEP_END
    # clone_parent_mesh = true
  []
  [patches]
    type = FullSolveMultiApp
    input_files = patches.i
    cli_args = 'seed=${seed};psic=${psic}'
    execute_on = 'INITIAL'
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = ./mesh/hole_hr0.1_hc1.msh
  []
  [fix_point]
    type = ExtraNodesetGenerator
    coord = '-50 -50 0'
    input = fmg 
    new_boundary = fix_point
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [d]
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  [fx]
  []
  [fy]
  []
  [hoop]
    order = CONSTANT
    family = MONOMIAL
  []
  [radial]
    order = CONSTANT
    family = MONOMIAL
  []
  [pressure]
    order = CONSTANT
    family = MONOMIAL
  []
  [psic]
    order = CONSTANT
    family = MONOMIAL
    [InitialCondition]
      type = ConstantIC
      value = ${psic}
    []
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
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
  [hoop]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hoop
    scalar_type = HoopStress
  []
  [radial]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = radial
    scalar_type = RadialStress
  []
  [pressure]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = pressure 
    scalar_type = Hydrostatic
  []
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
  []
[]

[Functions]
  [p_func]
    type = ADParsedFunction
    # expression = 'p0*t'
    expression = 'p0*exp(t/T0)'
    # expression = 'if(t<T0, p0*sin(pi*t/2/T0), p0)'
    symbol_names = 'p0 T0'
    symbol_values = '${p0} ${T0}'
  []
[]

[BCs]
  [pressure_x]
    type = ADPressure
    boundary = circle
    variable = 'disp_x'
    function = p_func
  []
  [pressure_y]
    type = ADPressure
    boundary = circle
    variable = 'disp_y'
    function = p_func
  []
  # [fix_x]
  #   type = ADDirichletBC
  #   boundary = fix_point
  #   variable = disp_x
  #   value = 0
  # []
  # [fix_y]
  #   type = ADDirichletBC
  #   boundary = fix_point
  #   variable = disp_y
  #   value = 0
  # []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  [psic]
    type = ADParsedMaterial
    property_name = psic 
    coupled_variables = 'psic'
    expression = 'psic'
    # outputs = exodus
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  # [nodeg]
  #   type = NoDegradation
  #   f_name = g
  #   phase_field = d
  #   function = 1
  # []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l '
    parameter_names = 'p a2 a3 eta '
    parameter_values = '2 1 0 1e-5'
  []
  [strain]
    type = ADComputeSmallStrain
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    # decomposition = NONE
    output_properties = 'psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
  []
[]

[Postprocessors]
  [Load]
    type = SideIntegralVariablePostprocessor
    boundary = circle
    variable = pressure
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
  []
[]

# [Preconditioning]
#   [smp]
#     type = SMP
#     full = true
#     petsc_options_iname = '-pc_type -pc_factor_shift_type '
#     petsc_options_value = '  lu NONZERO'
#   []
# []

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
  #                       '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
  #                       '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
  #                       '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  scaling_group_variables = 'disp_x disp_y'

  # l_abs_tol = 1e-8
  # l_max_its = 200
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_max_its = 200

  line_search = none
  fixed_point_max_its = 20
  # disable_fixed_point_residual_norm_check = true
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<0.1, 0.005, 0.0005)'
  #   growth_factor = 5
  #   cutback_factor_at_failure = 0.2
  # []
  # dt = 0.05
  dt = 1e-6
  # dtmin = 0.0001
  start_time = 0
  end_time = 120e-6
  # num_steps = 1
  # [TimeIntegrator]
  #   type = NewmarkBeta
  # []
  # relaxation_factor = 0.1
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
    minimum_time_interval = 1e-6
  []
  print_linear_residuals = false
  file_base = './out/hole_coh_p${p0}_r${r}_l${l}'
  interval = 1
  checkpoint = true
  [csv]
    file_base = './gold/hole_coh_p${p0}_r${r}_l${l}'
    type = CSV
  []
[]
