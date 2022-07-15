[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 8
  ymin = -4
  ymax = 4
  nx = 200
  ny = 200
[]
# h = 0.01

# [Adaptivity]
#   marker = marker
#   initial_marker = marker
#   initial_steps = 3
#   stop_time = 0
#   max_h_level = 3
#   [Markers]
#     [marker]
#       type = BoxMarker
#       bottom_left = '0 -0.1 0'
#       top_right = '0.1 0.1 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#   []
# []

[Problem]
  coord_type = RZ
[]

[Variables]
  [p]
  []
[]

[Kernels]
  [inertia_p]
    type = InertialForce
    variable = p
  []
  [diff_p]
    type = ADCoefMatDiffusion
    variable = p
    prop_names = 'D'
  []
  [source_p] # volume source
    type = ADCoefMatSource
    variable = p
    prop_names = 's'
    coefficient = -1
  []
[]

# [DiracKernels]
#   [point_source]
#     type = FunctionDiracSource
#     variable = p
#     function = s_func
#     point = '0.00 0.0 0.0'
#   []
# []

[Functions]
  # [s_func]
  #   type = ParsedFunction
  #   value = 'h:=(1 + tanh((t-t1)/tRT))*exp(-(t-t1)/tL)*cos(2*pi*fL*(t-t1) + pi/3);
  #           1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)'
  #   vars = 'fL      t1   tRT  tL  tP  p0 d1 c1      c2     rho'
  #   vals = '8.33e-2 0.07 0.01 0.8 1.0 1  9  12.2189 0.9404 1e-3'
  # []
  [s_func]
    type = ParsedFunction
    value = 'r:=sqrt(x^2+y^2);
            hsize:=0.02;
            r0:=0.1;
            deltah:=5500;
            h:=(1 + tanh((t-t1)/tRT))*exp(-(t-t1)/tL)*cos(2*pi*fL*(t-t1) + pi/3);
            a0:=1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)*deltah;
            if(r<r0, a0, 0)' # a0:=1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)*deltah;
    vars = 'fL      t1   tRT  tL  tP  p0 d1 c1      c2     rho'
    vals = '8.33e-2 0.07 0.01 0.8 1.0 1  9  12.2189 0.9404 1e-3'
  []
[]

[Materials]
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '444.44'
  []
  [diff]
    type = ADGenericConstantMaterial
    prop_names = 'D'
    prop_values = '1000'
  []
  [source] # volume source
    type = ADGenericFunctionMaterial
    prop_names = 's'
    prop_values = 's_func'
  []
[]

[Postprocessors]
  [./p_1]
    type = PointValue
    variable = p
    point = '2 0.0 0.0'
  [../]
  [./p_2]
    type = PointValue
    variable = p
    point = '3 0.0 0.0'
  [../]
  [./p_3]
    type = PointValue
    variable = p
    point = '4 0.0 0.0'
  [../]
  [./p_4]
    type = PointValue
    variable = p
    point = '5 0.0 0.0'
  [../]
[]

# [BCs]
#   [outer]
#     type = ADDirichletBC
#     variable = p
#     boundary = 'top right bottom'
#     value = 0
#   []
# []

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  end_time = 6
  # end_time = 0.5
  dt = 1e-3
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
[./csv]
    type = CSV
    delimiter = ','
    file_base = 'p_2drz'
  [../]
  [./exodus]
    type = Exodus
    interval = 100
    file_base = test_2drz
  []
[]