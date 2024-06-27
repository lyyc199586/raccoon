E = 32e3
nu = 0.2

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

u0 = 0.0025
t0 = 0.01
# refine = 3
l = 1

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gen] #h_c = 1, h_r = 0.25
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 40
    xmin = 0
    xmax = 100
    ymin = -20
    ymax = 20
  []
  [sub_upper]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x < 50 & y > 0'
    block_id = 1
  []
  [sub_lower]
    type = ParsedSubdomainMeshGenerator
    input = sub_upper
    combinatorial_geometry = 'x < 50 & y < 0'
    block_id = 2
  []
  [split]
    input = sub_lower
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
  []
[]

# [Adaptivity]
#   marker = initial
#   max_h_level = ${refine}
#   initial_marker = initial
#   initial_steps = ${refine}
#   cycles_per_step = ${refine}
#   [Markers]
#     [initial]
#       type = BoxMarker
#       bottom_left = '3.76 -0.51 0'
#       top_right = '4.24 0.51 0'
#       inside = REFINE
#       outside = DONT_MARK
#     []
#   []
# []

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  # [strain_zz]
  # []
[]

[AuxVariables]
  [d]
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
  []
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = strain_zz
  # []
[]

[Functions]
  [top_func]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${u0}'
  []
  [bottom_func]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 -${u0}'
  []
[]

[BCs]
  [ytop]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top
    function = top_func
  []
  [ybottom]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bottom_func
  []
  # [xtop]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = top
  #   value = 0
  # []
  # [xbottom]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = bottom
  #   value = 0
  # []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  # [degradation]
  #   type = RationalDegradationFunction
  #   property_name = g
  #   phase_field = d
  #   material_property_names = 'Gc psic xi c0 l'
  #   parameter_names = 'p a2 a3 eta'
  #   parameter_values = '2 1 0.0 1e-6'
  # []
  [nodeg]
    type = NoDegradation
    property_name = g
    phase_field = d 
  []
  [strain]
    type = ADComputeSmallStrain
    # type =  ADComputePlaneSmallStrain
    # out_of_plane_strain = strain_zz
    displacements = 'disp_x disp_y'
    outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = NONE
    decomposition = SPECTRAL
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre       boomeramg                 '
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = ${t0}
  end_time = ${t0}

  fixed_point_max_its = 5
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-4
  fixed_point_abs_tol = 1e-6

[]

[Outputs]
  [exodus]
    # sync_times = ${t0}
    type = Exodus
  []
  print_linear_residuals = false
  file_base = './pre_load_u${u0}'
  time_step_interval = 1
[]
