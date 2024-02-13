# MPa N mm

E = 10
E_mid = '${fparse E/2}'
nu = 0
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

K_mid = '${fparse E_mid/3/(1-2*nu)}'
G_mid = '${fparse E_mid/2/(1+nu)}'
Lambda_mid = '${fparse E_mid*nu/(1+nu)/(1-2*nu)}'

Gc = 0.1
l = 0.01 # [0.01, 0.02, 0.04, 0.08]
sigma_ts = 2
sigma_cs = 10
sigma_hs = '${fparse 2/3*sigma_ts*sigma_cs/(sigma_cs - sigma_ts)}'

# load velocity
v = 0.25

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_hs=${sigma_hs}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
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
    variable = 'disp_x psie_active'
    source_variable = 'disp_x psie_active'
  []
[]

[GlobalParams]
  # displacements = 'disp_x disp_y disp_z'
  displacements = 'disp_x'
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 2000
    # ny = 1
    # nz = 1
    xmax = 1
    # ymax = 0.0005
    # zmax = 0.0005
  []
  [mid]
    type = ParsedSubdomainMeshGenerator
    block_id = 1
    block_name = 'mid'
    combinatorial_geometry = 'x > 0.45 & x < 0.55'
    input = gen
  []
[]

[Variables]
  [disp_x]
  []
  # [disp_y]
  # []
  # [disp_z]
  # []
[]

[AuxVariables]
  [d]
  []
  [fx]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
  []
  # [solid_y]
  #   type = ADStressDivergenceTensors
  #   variable = disp_y
  #   component = 1
  # []
  # [solid_z]
  #   type = ADStressDivergenceTensors
  #   variable = disp_z
  #   component = 2
  # []
[]

[BCs]
  [fix_left]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [load_right]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = right
    function = bc_func
  []
[]

[Functions]
  [bc_func]
    type = ParsedFunction
    expression = 'v*t'
    symbol_names = 'v'
    symbol_values = '${v}'
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'Gc l'
    prop_values = '${Gc} ${l}'
  []
  [K]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'K'
    subdomain_to_prop_value = '0 ${K} 1 ${K_mid}'
    output_properties = 'K'
    outputs = exodus
  []
  [G]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'G'
    subdomain_to_prop_value = '0 ${G} 1 ${G_mid}'
  []
  [lambda]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'lambda'
    subdomain_to_prop_value = '0 ${Lambda} 1 ${Lambda_mid}'
  []
  # [no_deg]
  #   type = NoDegradation
  #   f_name = g
  #   function = 1
  #   phase_field = d
  # []
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
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active psie'
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
  [disp_right]
    type = PointValue
    point = '1 0 0'
    variable = disp_x
    outputs = 'csv exodus'
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = right
    outputs = 'csv exodus'
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
    outputs = 'csv exodus'
  []
[]

[VectorPostprocessors]
  [d]
    type = LineValueSampler
    variable = d
    start_point = '0 0 0'
    end_point = '1 0 0'
    sort_by = x
    num_points = 2000
    outputs = 'line'
    execute_on = FINAL
  []
[]


[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  dt = 0.02
  # [TimeStepper]
  #   type = FunctionDT 
  #   function = 'if(t < 0.8, 1e-2, 1e-3)'
  #   min_dt = 1e-4
  # []

  # dtmin = 5e-4
  end_time = 1

  fixed_point_max_its = 500
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 5e-3
    # file_base = './out/1d_bar_elasticity_with-h-correct_l${l}'
    file_base = './out/1d_bar_elasticity_l${l}'
  []
  [csv]
    type = CSV
    # file_base = './gold/1d_bar_with-h-correct_l${l}'
    file_base = './gold/1d_bar_l${l}'
  []
  [line]
    type = CSV
    # file_base = './gold/1d_bar_with-h-correct_l${l}_line'
    file_base = './gold/1d_bar_l${l}_line'
    # sync_times = '1'
    execute_on = 'FINAL'
  []
  print_linear_residuals = false
[]
