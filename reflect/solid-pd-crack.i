# use material properties in NPL paper
# BegoStone (with sigma_ts=20 MPa)
# crack at x=1, region=[0, 2]*[0, 0.5]
# test with nuc22 model

E = 0.02735
nu = 0
Gc = 21.88e-9
l = 0.1 # h = 0.02
delta = 0
# psic = 7.0e-9
sigma_ts = 20
sigma_cs = 100

rho = 1.995e-3


K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[MultiApps]
  [damage]
    type = TransientMultiApp
    execute_on = TIMESTEP_END
    input_files = damage.i
    # cli_args = 'Gc=${Gc};l=${l};psic=${psic}'
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};'
    # clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = damage
    source_variable = d
    variable = d
    execute_on = TIMESTEP_BEGIN
  []
  [to_d]
    type = MultiAppCopyTransfer
    to_multi_app = damage
    source_variable = 'disp_x disp_y psie_active'
    variable = 'disp_x disp_y psie_active'
    execute_on = TIMESTEP_END
  []
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 10
    # nx = 400
    # ny = 25
    xmin = 0
    xmax = 2
    ymin = 0
    ymax = 0.2
  []
  [add_crack]
    type = ParsedGenerateSideset
    input = gmg
    combinatorial_geometry = 'abs(x-1)<0.021'
    new_sideset_name = 'crack'
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
    [InitialCondition]
      type = ConstantIC
      boundary = crack
      value = 1
    []
  []
  [bounds_dummy]
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [accel_x]
  []
  [vel_x]
  []
  [accel_y]
  []
  [vel_y]
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    component = 0
    variable = disp_x
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    component = 1
    variable = disp_y
  []
  [inertia_x]
    type = ADInertialForce
    variable = 'disp_x'
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = 'disp_y'
    velocity = vel_y
    acceleration = accel_y
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  []
  [vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  []
  [stress_xx]
    type = ADRankTwoAux
    variable = 'stress_xx'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  []
  [psie_active]
    type = ADMaterialRealAux
    property = 'psie_active'
    variable = 'psie_active'
    execute_on = 'TIMESTEP_END'
  []
[]

[Functions]
  [f_load]
    type = ParsedFunction
    expression = 'if(t < T, amp*sin(pi*t/(T)), 0)'
    symbol_names = 'amp T'
    # symbol_values = '1e-3 1'
    symbol_values = '-10e-6 0.25'
  []
[]

[BCs]
  [left_in]
    # type = ADFunctionDirichletBC
    type = ADPressure
    displacements = 'disp_x disp_y'
    boundary = left
    variable = disp_x
    function = f_load
  []
[]

[Materials]
  # disc
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  # [nodegradation] # elastic test
  #   type = NoDegradation
  #   f_name = g 
  #   function = 1
  #   phase_field = d
  # []
  [degradation] # for nuc22
    type = PowerDegradationFunction
    f_name = g
    # function = (1-d)^p*(1-eta)+eta
    function = (1-d)^p+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  [strain]
    type = ADComputeSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # output_properties = 'psie_active'
    # outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
[]

[Postprocessors]
  [max_disp_x]
    type = NodalExtremeValue
    value_type = max 
    variable = disp_x
  []
[]

[Executioner]
  type = Transient
  # solve_type = LINEAR
  # [TimeIntegrator]
  #   type = CentralDifference
  #   solve_type = lumped
  #   # solve_type = consistent
  # []
  # end_time = 1.5
  # dt = 0.5e-3

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
                        '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
                        '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
                        '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true
  fixed_point_rel_tol = 1e-3
  fixed_point_abs_tol = 1e-5
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  end_time = 0.65
  # dt = 0.5e-3
  dt = 0.01
  # dt = 0.0005
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 0.01
    interval = 1
  []
  print_linear_residuals = false
  # file_base = './out/reflect_pd_compression'
  file_base = './out/reflect_pd_tension'
  interval = 1
  [pp]
    type = CSV
    # file_base = './gold/reflect_pd_compression'
    file_base = './gold/reflect_pd_tension'
    minimum_time_interval = 0.01
  []
[]