E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'

rho = 2.54e-9 # Mg/mm^3
Gc = 0.003
sigma_ts = 3.08 # MPa
psic = '${fparse sigma_ts^2/2/E}'
l = 1.25 # L = 1.25mm, l_ch = 11 mm

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Gc=${Gc};psic=${psic};l=${l}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    variable = d
    source_variable = d
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = psie_active
    source_variable = psie_active
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 400
    ny = 160
    xmin = 0
    xmax = 100
    ymin = -20
    ymax = 20
  []
[]

# [Adaptivity]
#   marker = marker
#   initial_marker = marker
#   initial_steps = 2
#   stop_time = 0
#   max_h_level = 2
#   [Markers]
#     [marker]
#       type = BoxMarker
#       bottom_left = '0 -5 0'
#       top_right = '100 5 0'
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
      function = 'if(y=0&x>=0&x<=50,1,0)'
    []
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
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
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    component = 1
    boundary = top
    constant = -1
  []
  [ybottom]
    type = ADPressure
    variable = disp_y
    component = 1
    boundary = bottom
    constant = -1
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G l Gc psic density'
    prop_values = '${E} ${K} ${G} ${l} ${Gc} ${psic} ${rho}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    function = (1-d)^p/((1-d)^p+(Gc/psic*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta
    phase_field = d
    material_property_names = 'Gc psic xi c0 l '
    parameter_names = 'p a2 a3 eta '
    parameter_values = '2 -0.5 0 1e-6'
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
  [disp_y]
    type = PointValue
    point = '0 20 0'
    variable = disp_y
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

  dt = 5e-7
  end_time = 80e-6

  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-8
  fixed_point_abs_tol = 1e-10

  [TimeIntegrator]
    type = NewmarkBeta
    gamma = '${fparse 5/6}'
    beta = '${fparse 4/9}'
  []
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  file_base = './coh_branch'
  interval = 2
[]
