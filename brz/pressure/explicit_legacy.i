# explicit solve

# basalt properties (MPa, N, mm, s)
E = 20.11e3
nu = 0.24
Gc = 0.1
sigma_ts = 11.31
sigma_cs = 159.08
rho = 2.74e-9

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# nucleation model
l = 3
delta = 5

# model parameter
r = 25
a = 10 # load arc angle (deg)
p = 300
t0 = 100e-6 # ramp time
tf = 200e-6

# adaptivity
refine = 3 # h_fine = 1/2^3 = 0.125

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};a=${a};r=${r};'
                'refine=${refine}'
    execute_on = 'TIMESTEP_END'
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
  []
  [left_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x < -${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'left_bnd'
    input = fmg
  []
  [right_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x > ${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'right_bnd'
    input = left_bnd
  []
[]

[Adaptivity]
  initial_marker = initial_marker
  initial_steps = ${refine}
  # marker = damage_marker
  max_h_level = ${refine}
  [Markers]
    # [damage_marker]
    #   type = ValueRangeMarker
    #   variable = d
    #   lower_bound = 0.0001
    #   upper_bound = 1
    # []
    # [strength_marker]
    #   type = ValueRangeMarker
    #   variable = f_nu_var
    #   lower_bound = -1e-2
    #   upper_bound = 1e-2
    # []
    # [combo_marker]
    #   type = ComboMarker
    #   markers = 'damage_marker combo_marker'
    # []
    [initial_marker]
      type = BoxMarker
      bottom_left = '-${r} -8 0'
      top_right = '${r} 8 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Functions]
  [load]
    # type = ADParsedFunction
    type = ParsedFunction
    # expression = 'if(t<t0, p*sin(pi*t/2/t0), p)'
    expression = 'p*sin(pi*t/2/t0)'
    symbol_names = 'p t0'
    symbol_values = '${p} ${t0}'
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
  []
  [fx]
  []
  [fy]
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
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
    save_in = fx
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
  # [solid_x]
  #   type = ADDynamicStressDivergenceTensors
  #   variable = disp_x
  #   component = 0
  #   save_in = fx
  # []
  # [solid_y]
  #   type = ADDynamicStressDivergenceTensors
  #   variable = disp_y
  #   component = 1
  #   save_in = fy
  # []
  [inertia_x]
    type = ADInertialForce
    variable = disp_x
    density = density
    # velocity = vel_x
    # acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
    density = density
    # velocity = vel_y
    # acceleration = accel_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

# [AuxKernels]
#   [accel_x] # Calculates and stores acceleration at the end of time step
#     type = NewmarkAccelAux
#     variable = accel_x
#     displacement = disp_x
#     velocity = vel_x
#     execute_on = timestep_end
#     beta = 0
#     gamma = 
#   []
#   [vel_x] # Calculates and stores velocity at the end of the time step
#     type = NewmarkVelAux
#     variable = vel_x
#     acceleration = accel_x
#     execute_on = timestep_end
#   []
#   [accel_y]
#     type = NewmarkAccelAux
#     variable = accel_y
#     displacement = disp_y
#     velocity = vel_y
#     execute_on = timestep_end
#   []
#   [vel_y]
#     type = NewmarkVelAux
#     variable = vel_y
#     acceleration = accel_y
#     execute_on = timestep_end
#   []
# []


[BCs]
  [fix_right_x]
    type = DirichletBC
    variable = disp_x
    boundary = right_bnd
    value = 0
  []
  [load_left_x]
    type = Pressure
    variable = disp_x
    boundary = left_bnd
    function = load
  []
  [load_left_y]
    type = Pressure
    variable = disp_y
    boundary = left_bnd
    function = load
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  # [reg_density]
  #   type = MaterialADConverter
  #   ad_props_in = 'density'
  #   reg_props_out = 'reg_density'
  # []
  # [nodegradation] # elastic test
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
    parameter_values = '2 1e-5'
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
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
    boundary = left_bnd
    outputs = 'pp exodus'
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = left_bnd
    outputs = 'pp exodus'
  []
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []

  dtmin = 1e-10
  start_time = 0
  end_time = ${tf}

  [TimeStepper]
    type = FunctionDT
    function = 'if(t<5.8e-5, 1e-7, 0.5e-7)'
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 1e-8
    execute_on = 'INITIAL TIMESTEP_END FAILED'
  []
  # minimum_time_interval = 1e-6
  print_linear_residuals = false
  
  # file_base = './out/brz_nuc22_p${p}_a${a}_l${l}_d${delta}_ref${refine}/brz_nuc22_p${p}_a${a}_l${l}_d${delta}_ref${refine}'
  file_base = './out/brz_explicit_nuc22_p${p}_a${a}_l${l}_d${delta}/brz'
  # interval = 1
  checkpoint = true
  [pp]
    type = CSV
    file_base = './gold/pp_brz_explicit_nuc22_p${p}_a${a}_l${l}_d${delta}_iref${refine}'
  []
[]

[Debug]
  show_functors = true

[]
