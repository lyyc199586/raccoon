# basalt
E = 20.11e3
nu = 0.24
rho = 2.74e-9
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# model parameter
r = 25
a = 10
# h = 1
p = 300
t0 = 100e-6 # ramp time
tf = 200e-6
# nsegs = '${fparse ceil(2*pi*r/h)}'

[Mesh]
  # [circ]
  #   type = ParsedCurveGenerator
  #   x_formula = 'r*cos(t*2*pi)'
  #   y_formula = 'r*sin(t*2*pi)'
  #   section_bounding_t_values = '0 1'
  #   constant_names = 'pi r'
  #   constant_expressions = '${fparse pi} ${r}'
  #   nums_segments = '${nsegs}'
  #   is_closed_loop = true
  # []
  # [disk]
  #   type = XYDelaunayGenerator
  #   boundary = circ
  #   desired_area = 0.5
  #   refine_boundary = false
  #   output_boundary = 'circ'
  #   output_subdomain_name = 'disk'
  #   smooth_triangulation = true
  # []
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/disc_r25_h1.msh'
    # show_info = true
  []
  [smooth]
    type = SmoothMeshGenerator
    input = fmg
    iterations = 10
  []
  [box]
    type = SubdomainBoundingBoxGenerator
    input = smooth
    bottom_left = '-${r} -8.0 0.0'
    top_right = '${r} 8.0 0.0'
    block_id = 2
    block_name = center
    restricted_subdomains = 'disc'
  []
  [refine]
    type = RefineBlockGenerator
    input = box
    refinement = 2
    block = 'center'
  []
  [circ]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-${r}^2) < 1'
    new_sideset_name = 'circ'
    input = refine
  []
  # [ccg]
  #   type = CircularBoundaryCorrectionGenerator
  #   input = circ
  #   input_mesh_circular_boundaries = 'circ'
  #   custom_circular_tolerance = 1e-1
  # []
  [left_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x < -${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'left_bnd'
    included_boundaries = 'circ'
    input = circ
  []
  [right_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x > ${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'right_bnd'
    included_boundaries = 'circ'
    input = left_bnd
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
    initial_condition = 0
  []
  [vel_x]
  []
  [accel_x]
  []
  [vel_y]
  []
  [accel_y]
  []
  [fx]
  []
  [fy]
  []
[]

[Kernels]
  # [DynamicTensorMechanics]
  #   displacements = 'disp_x disp_y'
  # []
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
    displacements = 'disp_x disp_y'
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
    displacements = 'disp_x disp_y'
  []
  [inertia_x]
    type = InertialForce
    variable = disp_x
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[AuxKernels]
  [accel_x]
    type = TestNewmarkTI
    variable = accel_x
    displacement = disp_x
    first = false
  []
  [vel_x]
    type = TestNewmarkTI
    variable = vel_x
    displacement = disp_x
  []
  [accel_y]
    type = TestNewmarkTI
    variable = accel_y
    displacement = disp_y
    first = false
  []
  [vel_y]
    type = TestNewmarkTI
    variable = vel_y
    displacement = disp_y
  []
[]

[BCs]
  [fix_right]
    type = DirichletBC
    variable = disp_x
    boundary = right_bnd
    value = 0.0
  []
  [load_left_x]
    type = ADPressure
    boundary = left_bnd
    variable = disp_x
    function = load
    displacements = 'disp_x disp_y'
  []
  [load_left_y]
    type = ADPressure
    boundary = left_bnd
    variable = disp_y
    function = load
    displacements = 'disp_x disp_y'
  []
[]

[Functions]
  # [disp]
  #   type = PiecewiseLinear
  #   x = '0.0 5e-5' # time
  #   y = '0.0 1e-1' # displacement
  # []
  [load]
    type = ParsedFunction
    expression = 'p*sin(pi*t/2/t0)'
    symbol_names = 'p t0'
    symbol_values = '${p} ${t0}'
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda'
    prop_values = '${E} ${K} ${G} ${Lambda}'
  []
  [density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = '${rho}'
  []
  [elasticity_tensor_block]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 20.11e3
    poissons_ratio = 0.24
  []
  # [strain_block]
  #   type = ADComputeIncrementalSmallStrain
  #   displacements = 'disp_x disp_y'
  #   implicit = false
  # []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
  # [stress_block]
  #   type = ADComputeLinearElasticStress
  #   outputs = exodus
  #   output_properties = 'stress'
  # []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # output_properties = 'psie_active'
    outputs = exodus
  []
  [nodegradation] # elastic test
    type = NoDegradation
    f_name = g 
    function = 1
    phase_field = d
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = ${tf}
  dt = 1e-8

  [TimeIntegrator]
    type = CentralDifference
    # solve_type = lumped
    # use_constant_mass = true
  []
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = left_bnd
    # outputs = 'pp exodus'
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = left_bnd
    # outputs = 'pp exodus'
  []
[]

[Outputs]
  # minimum_time_interval = 1e-6
  exodus = true
[]