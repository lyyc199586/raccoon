# begostone properties
E = 6.16e3
nu = 0.2
psic = 8.1e-3
Gc = 3.656e-2
rho_s = 1.995e-3
l = 0.25

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'

# mesh paramters
h = 0.125 # coarse mesh size
length = 3.25 # [0, 3.25]
width = 2 # [-1, 1]
# refine = 3 #fine mesh size 0.015625
refine = 2
nx = '${fparse length/h}'
ny = '${fparse width/h}'

# velocity and time setting
v0 = -1 # mm/s
tf = 2e-3 # ms
dt = 1e-5
################################################################################

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${nx}
    ny = ${ny}
    xmax = ${length}
    ymin = '${fparse -1*width/2}'
    ymax = '${fparse width/2}'
  []
  [top_center]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'y>0.99 & x<=0.375'
    new_sideset_name = 'top_center'
    input = gen
  []
[]

[Adaptivity]
  marker = marker
  initial_marker = marker
  initial_steps = ${refine}
  stop_time = 0
  max_h_level = 0
  [Markers]
    [marker]
      type = BoxMarker
      bottom_left = '0 0.5 0'
      top_right = '${length} 1 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Problem]
  coord_type = RZ
[]

[GlobalParams]
  displacements = 'disp_r disp_z'
[]

[Variables]
  [disp_r]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [d]
  []
  # [psie_active]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
[]

# [AuxKernels]
#   # [stress_rr]
#   #   order = CONSTANT
#   #   family = MONOMIAL
#   # []
#   # [stress_zz]
#   #   order = CONSTANT
#   #   family = MONOMIAL
#   # []
#   # [bounds_dummy]
#   # []
# []

[Kernels]
  [stress_rr]
    type = ADStressDivergenceRZTensors
    component = 0
    variable = disp_r
  []
  [stress_zz]
    type = ADStressDivergenceRZTensors
    component = 1
    variable = disp_z
  []
  [inertia_rr]
    type = InertialForce
    variable = 'disp_r'
  []
  [inertia_zz]
    type = InertialForce
    variable = 'disp_z'
  []
[]

[Functions]
  # [bc_r] # constant in space
  #   type = PiecewiseLinear
  #   axis = x
  #   x = '0 0.375'
  #   y = '1 1'
  # []
  # [bc_r] # linearly decrease in space
  #   type = PiecewiseLinear
  #   axis = x
  #   x = '0 0.375'
  #   y = '1 0.1'
  # []
  [bc_r] # smoothed in space (0.25, 0.375)
    type = ParsedFunction
    value = 'if(x<0.25, 1, 0.5*(1 + cos(3.1415926/0.125*(x-0.25))))'
  []
  [bc_t] 
    type = ParsedFunction
    value = 'if(t<0.1*${tf}, ${v0}*(t - 5*t^2/${tf}), 0.05*${v0}*${tf})' # linearly decrease
    # value = '${v0}*t' # velocity constant in time
  []
  [bc_func]
    type = CompositeFunction
    functions = 'bc_r bc_t'
  []
[]

[BCs]
  [top_z]
    type = FunctionDirichletBC
    variable = 'disp_z'
    boundary = 'top_center'
    function = bc_func
    preset = false
  []
  [bottom_z]
    type = DirichletBC
    variable = 'disp_z'
    boundary = 'bottom'
    value = 0
  []
  [axial_x]
    type = DirichletBC
    variable = 'disp_r'
    boundary = 'left'
    value = 0
  []
[]

[Materials]
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = ${rho_s}
  []
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'K G l Gc psic'
    prop_values = '${K} ${G} ${l} ${Gc} ${psic}'
  []
  [no_degradation]
    type = NoDegradation
    f_name = g
    function = 1
    phase_field = d
  []
  [strain]
    type = ADComputeAxisymmetricRZSmallStrain
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

[Executioner]
  type = Transient
  solve_type = LINEAR
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []
  end_time = ${tf}
  dt = ${dt}
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
    file_base = './gold/elastic-1'
  []
[]
