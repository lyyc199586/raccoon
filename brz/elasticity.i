# 2D plane stress, dynamic simualtions of brazilian tests

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
l = 1
delta = 0

# model parameter
r = 25
a = 10 # load arc angle (deg)
p = 1000
t0 = 50e-6 # ramp time
tf = 200e-6

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};a=${a};r=${r}'
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
  use_displaced_mesh = false
  gamma = 0.5
  beta = 0.25
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/disc_r25_h1.msh'
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

[Functions]
  [load]
    type = ADParsedFunction
    expression = 'if(t<t0, p*sin(pi*t/2/t0), p)'
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
  [inertia_x]
    type = InertialForce
    variable = disp_x
    density = reg_density
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    density = reg_density
    velocity = vel_y
    acceleration = accel_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[AuxKernels]
  [accel_x] # Calculates and stores acceleration at the end of time step
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  []
  [vel_x] # Calculates and stores velocity at the end of the time step
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  []
[]

[BCs]
  [fix_right_x]
    type = DirichletBC
    variable = disp_x
    boundary = right_bnd
    value = 0
  []
  [load_left_x]
    type = ADPressure
    variable = disp_x
    boundary = left_bnd
    function = load
  []
  [load_left_y]
    type = ADPressure
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
  [reg_density]
    type = MaterialADConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
  []
  [nodegradation] # elastic test
    type = NoDegradation
    f_name = g 
    function = 1
    phase_field = d
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
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

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8

  # dt = 5e-8 # 0.05 us
  dt = 1e-6
  dtmin = 5e-9
  end_time = ${tf}


  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = true
  # fixed_point_rel_tol = 1e-6
  # fixed_point_abs_tol = 1e-8
  fixed_point_rel_tol = 1e-3
  fixed_point_abs_tol = 1e-5

  [TimeIntegrator]
    type = NewmarkBeta
    gamma = 0.5
    beta = 0.25
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
  []
  print_linear_residuals = false
  file_base = './out/brz_elastic_p${p}_t0${t0}'
  interval = 1
  [pp]
    type = CSV
    file_base = './csv/pp_brz_elastic_p${p}_t0${t0}'
  []
[]