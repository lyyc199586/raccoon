# 2D plane stress, dynamic simualtions of brazilian tests

# basalt properties (MPa, N, mm, s)
E = 20.11e3
nu = 0.24
Gc = 0.1
sigma_ts = 11.31
# sigma_cs = 159.08
sigma_cs = ${fparse sigma_ts*30}
rho = 2.74e-9

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# nucleation model
l = 2.5
delta = 5

# model parameter
r = 25
a = 20 # load arc angle (deg)
# p = 300
u = 1 # maximum point displacement
t0 = 100e-6 # ramp time
tf = 200e-6

# adaptivity
refine = 3 # h_fine = 1/2^3 = 0.125

# hht parameters
hht_alpha = -0.25
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};a=${a};r=${r};refine=${refine}'
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
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
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
  # marker = combo_marker
  max_h_level = ${refine}
  [Markers]
    # [damage_marker]
    #   type = ValueRangeMarker
    #   variable = d
    #   lower_bound = 0.000001
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
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
    # alpha = 0.1
    save_in = fx
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    # alpha = 0.1
    save_in = fy
  []
  # [solid_x]
  #   type = ADStressDivergenceTensors
  #   variable = disp_x
  #   component = 0
  #   save_in = fx
  # []
  # [solid_y]
  #   type = ADStressDivergenceTensors
  #   variable = disp_y
  #   component = 1
  #   save_in = fy
  # []
  [inertia_x]
    type = ADInertialForce
    variable = disp_x
    density = density
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
    density = density
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
    # function = (1-d)^p*(1-eta)+eta
    function = (1-d)^p+eta
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
  [max_d]
    type = NodalMaxValue
    variable = d
    outputs = 'pp exodus'
  []
  [max_disp]
    type = NodalMaxValue
    variable = disp_x
    outputs = 'pp exodus'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -ksp_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type -sub_pc_factor_shift_amount ' 
  # petsc_options_value = 'asm      gmres     200                preonly       lu           1  NONZERO 1e-14  '
  automatic_scaling = true

  line_search = bt

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  # dt = 5e-8 # 0.05 us
  dt = 1e-6
  # dtmin = 5e-9
  end_time = ${tf}


  # fixed_point_max_its = 50
  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = true
  # fixed_point_rel_tol = 1e-6
  # fixed_point_abs_tol = 1e-8
  fixed_point_rel_tol = 1e-3
  fixed_point_abs_tol = 1e-5

  # [TimeIntegrator]
  #   type = NewmarkBeta
  #   gamma = 0.5
  #   beta = 0.25
  # []
[]

[Outputs]
  [exodus]
    type = Exodus
    minimum_time_interval = 1e-6
    interval = 1
  []
  # minimum_time_interval = 1e-6
  print_linear_residuals = false
  file_base = './out/brz_nuc22_u${u}_a${a}_l${l}_d${delta}_ref${refine}/brz_nuc22_u${u}_a${a}_l${l}_d${delta}_sratio${fparse int(sigma_cs/sigma_ts)}_it50'
  # file_base = './out/hert_nuc22_u${u}_a${a}_l${l}_d${delta}/hert_newmark_nuc22_u${u}_a${a}_l${l}_d${delta}_iref${refine}'
  interval = 1
  checkpoint = true
  [pp]
    type = CSV
    file_base = './csv/pp_hert_newmark_nuc22_u${u}_a${a}_l${l}_d${delta}_sratio${fparse int(sigma_cs/sigma_ts)}_it50'
  []
[]