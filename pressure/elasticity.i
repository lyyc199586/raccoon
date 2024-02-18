# crack from pressurized hole

# BegoStone mat prop (MPa, N, mm)
E = 6.26e3
nu = 0.2
Gc = 3.656e-2
sigma_ts = 10
# sigma_cs = 37.4
l = 0.5
r = 5

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
psic = ${fparse sigma_ts^2/2/E}

p0 = 200

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = 'psie_active disp_x disp_y'
    source_variable = 'psie_active disp_x disp_y'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};'
    execute_on = TIMESTEP_END
    # clone_parent_mesh = true
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = ./mesh/hole.msh
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
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
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
    scalar_type = AxialStress
  []
[]

[Functions]
  [p_func]
    type = ADParsedFunction
    expression = 'p0*t'
    symbol_names = 'p0'
    symbol_values = '${p0}'
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
[]

[ICs]
  [defect]
    type = MultiSmoothSuperellipsoidIC
    variable = d
    bubspac = '5 5'
    numbub = '10 10'
    invalue = 1
    outvalue = 0
    semiaxis_a = '2.5 1'
    semiaxis_b = '1 2.5'
    semiaxis_c = '1 1'
    exponent = '2 2'
    rand_seed = 3
    prevent_overlap = true
    check_extremes = true
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${psic}'
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
    parameter_values = '2 -0.5 0 1e-6'
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
    outputs = exodus
  []
[]

[Postprocessors]
  [Fx]
    type = NodalSum
    boundary = circle
    variable = fx
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
  #                       '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
  #                       '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
  #                       '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 20

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-3
  fixed_point_abs_tol = 1e-5

  dt = 0.1
  start_time = 0
  end_time = 1
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
    minimum_time_interval = 1e-7
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