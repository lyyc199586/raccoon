# basalt
E = 20.11e3
nu = 0.24
rho = 2.74e-9
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

Gc = 0.1
sigma_ts = 11.31
sigma_cs = 159.08
l = 3
delta = 5
refine = 2

# model parameter
r = 25
# a = 10
# p = 300
u = 1
t0 = 100e-6 # ramp time
tf = 75e-6
# nsegs = '${fparse ceil(2*pi*r/h)}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};r=${r};refine=${refine}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = 'd f_nu_var'
    source_variable = 'd f_nu_var'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  # use_displaced_mesh = false
  use_displaced_mesh = true
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/disc_r25_h1.msh'
    show_info = true
  []
  [smooth]
    type = SmoothMeshGenerator
    input = fmg
    iterations = 10
  []
  [circ]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-${r}^2) < 1'
    new_sideset_name = 'circ'
    input = smooth
  []
  [left_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x < -${r}/2'
    new_sideset_name = 'left_bnd'
    included_boundaries = 'circ'
    input = circ
  []
  [right_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x > ${r}/2'
    new_sideset_name = 'right_bnd'
    included_boundaries = 'circ'
    input = left_bnd
  []
[]

[Adaptivity]
  initial_marker = initial_marker
  initial_steps = ${refine}
  max_h_level = ${refine}
  [Markers]
    [initial_marker]
      type = BoxMarker
      bottom_left = '-${r} -8 0'
      top_right = '${r} 8 0'
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
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
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

[Functions]
  [point_disp]
    type = ADParsedFunction
    expression = 'u*(-cos(pi*t/t0) + 1)/2'
    symbol_names = 'u t0'
    symbol_values = '${u} ${t0}'
  []
  [left_bc_func]
    type = ADParsedFunction
    expression = 'dist:=u*(-cos(pi*t/t0) + 1)/2;
                  if(abs(y) < sqrt(r*dist), dist - y^2/2/r, 0)'
    symbol_names = 'u t0 r'
    symbol_values = '${u} ${t0} ${r}'
  []
  [right_bc_func]
    type = ConstantFunction
    value = 0
  []
  [p_func] # penalty function for hertzian contact boundary
    type = ADParsedFunction
    expression = 'dist:=u*(-cos(pi*t/t0) + 1)/2;
                  if(abs(y) < sqrt(r*dist), p, 0)'
    symbol_names = 'u t0 r p'
    symbol_values = '${u} ${t0} ${r} 1e6'
  []
[]

[BCs]
  [left_arc_x]
    type = ADFunctionContactBC
    variable = disp_x
    boundary = left_bnd
    function = left_bc_func
    penalty_function = p_func
  []
  [right_arc_x]
    type = ADFunctionContactBC
    variable = disp_x
    boundary = right_bnd
    function = right_bc_func
    penalty_function = p_func
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc}'
  []
  [density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = '${rho}'
  []
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
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
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

[Executioner]
  type = Transient
  start_time = 0
  end_time = ${tf}
  dt = 1e-8

  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 5e-7
    execute_on = 'INITIAL TIMESTEP_END FAILED'
  []
  print_linear_residuals = false
  file_base = './out/brz_cd_hertian_nuc22_u${u}_l${l}_d${delta}'
  checkpoint = true
  [pp]
    type = CSV
    file_base = './gold/pp_brz_cd_hertian_nuc22_u${u}_l${l}_d${delta}'
  []
[]