## graphite
# E = 9.8e3 # 9.8 GPa
# nu = 0.13

# Gc = 9.1e-2 # 91 N/m
# l = 0.35
# sigma_ts = 27
# sigma_cs = 77
# delta = 1.16
## -----------------

## titania
# E = 250e3 # 250 Gpa
# nu = 0.29

# Gc = 3.6e-2 # 36 N/m
# l = 0.35
# sigma_ts = 100
# sigma_cs = 1232
# delta = 4.41
## ------------------

## c-300 steel
# E = 190e3 # 190 Gpa
# nu = 0.3

# Gc = 22.2 # 22.2 N/mm
# l = 1
# sigma_ts = 1158
# sigma_cs = 5280 # 11580
# delta = 4
## -------------------

## glass
# E = 6.25e4 # 0.0625 TPa
# nu = 0.19

# Gc = 1.6e-2 # 1.6e-8 TPa.mm
# l = 0.04
# sigma_ts = 50
# sigma_cs = 100
# delta = 2

# dynamic branching

# E = 32e3 # 32 GPa
# nu = 0.2
# rho = 2.54e-9 # Mg/mm^3
# Gc = 0.003
# sigma_ts = 3.08 # MPa
# sigma_cs = 30.8
# # psic = '${fparse sigma_ts^2/2/E}'
# l = 2 # L = 1.25mm, l_ch = 11 mm
# delta = 4.75

# quasi-static branching
# E = 20e3
# nu = 0.3
# Gc = 8.9e-2
# sigma_ts = 137
# sigma_cs = 411
# l = 0.01
# delta = 5

# BegoStone
# # E = 2.735e4
# # E = 4.77e3
# E = 6.16e3
# nu = 0.2
# # Gc = 2.188e-2
# # Gc = 3.656e-3
# Gc = 3.656e-2
# sigma_ts = 5
# # sigma_cs = 22.27
# # sigma_cs = 100
# sigma_cs = 25
# l = 0.8
# delta = 12

# soda-lime glass
E = 72e3
nu = 0.25
Gc = 9e-3
sigma_ts = 30
sigma_cs = 330

l = 0.25
delta = 0

# ---------------------------------

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
c1 = '${fparse (1+nu)*sqrt(Gc)/sqrt(2*pi*E)}'
c2 = '${fparse (3-nu)/(1+nu)}'

# shape and scale
# a = 10 # crack length
a = 5
h = 0.25 # coase mesh size
length = '${fparse 6*a}'
width = '${fparse 2*a}'
nx = '${fparse length/h}'
ny = '${fparse width/h}'
# refine = 3 # fine mesh size: 0.025
refine = 4 # fine mesh size: 0.015625

[Functions]
  [bc_func]
    type = ParsedFunction
    value = c1*((x-20*t)^2+y^2)^(0.25)*(c2-cos(atan2(y,(x-20*t))))*sin(0.5*atan2(y,(x-20*t)))
    vars = 'c1 c2'
    vals = '${c1} ${c2}'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_cs=${sigma_cs};delta=${delta};nx=${nx};ny=${ny};refine=${refine};length=${length};a=${a}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    variable = 'd f_nu_var'
    source_variable = 'd f_nu_var'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${nx}
    ny = ${ny}
    xmax = ${length}
    ymin = '${fparse -1*a}'
    ymax = ${a}
  []
  [gen2]
    type = ExtraNodesetGenerator
    input = gen
    new_boundary = fix_point
    coord = '0 ${fparse -1*a}' # fix left bottom point
  []
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
      refine = 0.0001
    []
    [initial_tip]
      type = BoxMarker
      bottom_left = '0 -${fparse 2*l} 0'
      top_right = '${fparse a + 2*l} ${fparse 2*l} 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
  []
[]

[AuxVariables]
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=${a},1,0)'
    []
  []
  [f_x]
  []
  [f_y]
  []
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = f_x
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = f_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = fix_point
    value = 0
  []
  [bottom_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bc_func
  []
  [top_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = bc_func
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
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
    # outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie psie_active'
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
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right bottom'
  []
  [Jint_over_Gc]
    type = ParsedPostprocessor
    function = 'Jint/${Gc}'
    pp_names = 'Jint'
    use_t = false
  []
  [bot_react]
    type = NodalSum
    variable = f_y
    boundary = bottom
  []
  [top_react]
    type = NodalSum
    variable = f_y
    boundary = top
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

  start_time = 0
  end_time = 5e-1 # for a = 5
  dt = 1e-3
  # end_time = 1 # for a = 10
  # dt = 1e-3

  # fast
  # fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  # fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  # fixed_point_rel_tol = 1e-5
  # fixed_point_abs_tol = 1e-6
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 10
  []
  file_base = './out/soda_gc${Gc}_l${l}_delta${delta}/soda_gc${Gc}_l${l}_delta${delta}'
  print_linear_residuals = false
  [csv]
    type = CSV
  []
[]
