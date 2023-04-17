# soda-lime glass
E = 72e3 # 32 GPa
nu = 0.25
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2.44e-9 # Mg/mm^3
Gc = 8.89e-3 # N/mm -> 3 J/m^2
# sigma_ts = 41 # MPa, sts and scs from guessing
sigma_ts = 30
sigma_cs = 330
p = 25

# l = 0.075
# delta = -0.2 # haven't tested
refine = 6 # h=1, h_ref=0.015625

l = 0.25
delta = -0.6
[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};'
      'sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};refine=${refine};p=${p}'
    execute_on = 'TIMESTEP_END'
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
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
[]

[Functions]
  [p_func] # trapezoidal loading pulse
    type = PiecewiseLinear
    x = '0 15e-6 60e-6 75e-6 80e-6'
    y = '0 ${p} ${p} 0 0'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gen]
    type = FileMeshGenerator
    file = './mesh/half.msh'
  []
  # [toplayer]
  #   type = ParsedSubdomainMeshGenerator
  #   input = gmg
  #   combinatorial_geometry = 'y > 74'
  #   block_id = 1
  #   block_name = top_layer
  # []
  [noncrack]
    type = BoundingBoxNodeSetGenerator
    input = gen
    new_boundary = noncrack
    bottom_left = '26.9 0 0'
    top_right = '100.1 0 0'
  []
  construct_side_list_from_node_list = true
[]

[Adaptivity]
  initial_marker = initial_tip
  initial_steps = ${refine}
  marker = damage_marker
  max_h_level = ${refine}
  [Markers]
    [damage_marker]
      type = ValueThresholdMarker
      variable = d
      refine = 0.001
    []
    [initial_tip]
      type = BoxMarker
      bottom_left = '26 0 0'
      top_right = '28 1 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Variables]
  [disp_x]
    # initial_from_file_var = 'disp_x' 
    # initial_from_file_timestep = LATEST
  []
  [disp_y]
    # initial_from_file_var = 'disp_y' 
    # initial_from_file_timestep = LATEST
  []
  # [strain_zz]
  #   initial_from_file_var = 'strain_zz' 
  #   initial_from_file_timestep = LATEST
  # []
[]

[AuxVariables]
  [fx]
  []
  [fy]
  []
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=19&x<=27,1,0)'
    # []
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
  [inertia_x]
    type = InertialForce
    variable = disp_x
    density = reg_density
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    density = reg_density
  []
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  # []
[]

[BCs]
  # [fix_top_x]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = top
  #   value = 0
  # []
  # [fix_top_y]
  #   type = DirichletBC
  #   variable = disp_y
  #   boundary = top
  #   value = 0
  # []
  # [dashpot_top_x]
  #   type = DashpotBC
  #   boundary = top
  #   component = 0
  #   disp_x = disp_x
  #   variable = disp_x
  #   coefficient = 0.5
  # []
  # [dashpot_top_y]
  #   type = DashpotBC
  #   boundary = top
  #   component = 1
  #   disp_x = disp_x
  #   variable = disp_y
  #   coefficient = 0.5
  # []
  [fix_center_y]
    type = DirichletBC
    variable = disp_y
    boundary = noncrack
    value = 0
  []
  [pressue_x]
    type = ADPressure
    # component = 0
    variable = disp_x
    displacements = 'disp_x disp_y'
    boundary = 'v-partial'
    function = p_func
  []
  [pressue_y]
    type = ADPressure
    # component = 1
    variable = disp_y
    displacements = 'disp_x disp_y'
    boundary = 'v-partial'
    function = p_func
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  [reg_density]
    type = MaterialADConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
  []
  [strain]
    # type = ADComputePlaneSmallStrain
    type = ADComputeSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
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
  [Fy]
    type = NodalSum
    variable = fy
    boundary = v-partial
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = v-partial
  []
  [disp_x]
    type = PointValue
    point = '0 8.493 0'
    variable = disp_x
  []
  # [Jint]
  #   type = PhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'left bottom right top' # ? need to define in mesh?
  # []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8

  dt = 5e-8 # 0.05 us
  end_time = 80e-6

  # restart
  # start_time = 80e-6
  # end_time = 120e-6

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = true
  # fixed_point_rel_tol = 1e-6
  # fixed_point_abs_tol = 1e-8
  fixed_point_rel_tol = 1e-3
  fixed_point_abs_tol = 1e-5

  [TimeIntegrator]
    type = NewmarkBeta
    # gamma = '${fparse 5/6}'
    # beta = '${fparse 4/9}'
    gamma = 0.5
    beta = 0.25
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 10
  []
  print_linear_residuals = false
  file_base = './out/free_top/soda_p${p}_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  interval = 1
  [csv]
    type = CSV
  []
[]
