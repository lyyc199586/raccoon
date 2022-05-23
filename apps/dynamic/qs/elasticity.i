E = 3.24e3 # 32 GPa
nu = 0.35
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
# psic = '${fparse sigma_ts^2/2/E}'

rho = 1.19e-9 # Mg/mm^3

## case a

case = a
Gc = 1.588 # case a
l = 0.2
du = 0.06

## case b

# case = b
# Gc = 5.063 # case b
# l = 0.4
# du = 0.1

## case c

# case = c
# Gc = 9.420 # case c
# l = 0.6
# du = 0.14

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = 'psie_active'
    source_variable = 'psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 640
    ny = 320
    xmin = 0
    xmax = 32
    ymin = -8
    ymax = 8
  []
[]

# [Adaptivity]
#   marker = marker2
#   initial_marker = marker1
#   initial_steps = 1
#   stop_time = 0
#   max_h_level = 1
#   [Markers]
#     [marker1]
#       type = BoxMarker
#       bottom_left = '0 -2 0'
#       top_right = '32 2 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#     [marker2]
#       type = BoxMarker
#       bottom_left = '0 -1 0'
#       top_right = '32 1 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#   []
# []

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [fy]
  []
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=4,1,0)'
    []
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    # use_displaced_mesh = true
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
    # use_displaced_mesh = true
  []
[]

[BCs]
  [ytop]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = bc_top
  []
  [ybottom]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bc_bottom
  []
[]

[Functions]
  [bc_top]
    type = ParsedFunction
    value = 'du*t'
    vars = 'du'
    vals = ${du}
  []
  [bc_bottom]
    type = ParsedFunction
    value = '-du*t'
    vars = 'du'
    vals = ${du}
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
    parameter_values = '2 1e-6'
  []
  [reg_density]
    type = MaterialConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
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
    output_properties = 'elastic_strain psie_active'
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
    boundary = top
  []
  [out_disp_y]
    type = PointValue
    point = '0 8 0'
    variable = disp_y
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top' # ? need to define in mesh?
  []
  [external_work]
    type = ExternalWork
    boundary = 'top'
    forces = 'fy'
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [kinetic_energy]
    type = KineticEnergy 
    displacements = 'disp_x disp_y'
    density = density
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = 0.1
  end_time = 1

  fixed_point_max_its = 100
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

[]

[Outputs]
  exodus = true
  checkpoint = true
  print_linear_residuals = false
  file_base = './at1_qs_${case}_l${l}'
  interval = 1
  [./csv]
    type = CSV 
  [../]
[]
