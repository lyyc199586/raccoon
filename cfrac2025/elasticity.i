# material properties of PMMA (from https://cfrac2025.pt/benchmark)
# MPa, N, mm, us
# Plane strain

E = 6e3
nu = 0.3
rho = 1.18e3
Gc = 0.0011
l = 1 # lch= 3/8*E*Gc/sts**2
refine = 2 # h_fine = 0.25

# strength, from elastodynamic simulations
sigma_ts = 1 # MPa
sigma_cs = 10
sigma_hs = '${fparse 2/3*sigma_ts*sigma_cs/(sigma_cs - sigma_ts)}'

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# impact speed: see the actual boundary volocity from Figure 21
# TAF2 and THOM: 22, 
# TAF1: 30.5
# T3DE: 31.8
v_impact = 0.022  # mm/us
t0 = 30            # ramp up time
tf = 200

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

# out filename
filebase = 'nuc_v${v_impact}_l${l}_ts${sigma_ts}_cs${sigma_cs}'
# filebase = 'elastodynamic'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_hs=${sigma_hs};refine=${refine}'
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
    # variable = 'disp_x disp_y strain_zz psie_active'
    # source_variable = 'disp_x disp_y strain_zz psie_active'
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/plate_h1.0.msh'
  []
  [load]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x<1e-3 & abs(y) < 20.001'
    input = fmg
    new_sideset_name = 'load'
  []
[]

[Adaptivity]
  marker = combo_marker
  max_h_level = ${refine}
  cycles_per_step = 2
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 1e-6
      upper_bound = 1
    []
    [strength_marker]
      type = ValueRangeMarker
      variable = f_nu_var
      lower_bound = -1e-4
      upper_bound = 1e-4
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker strength_marker'
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  # [strain_zz]
  # []
[]

[AuxVariables]
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  [vel_z]
  []
  [fx]
  []
  [fy]
  []
  [d]
  []
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [s1]
    order = CONSTANT
    family = MONOMIAL
  []
  [s2]
    order = CONSTANT
    family = MONOMIAL
  []
  [sxx]
    order = CONSTANT
    family = MONOMIAL
  []
  [syy]
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
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
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
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  # []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [sxx]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = sxx
    index_i = 0
    index_j = 0
    execute_on = 'TIMESTEP_END'
  []
  [syy]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = syy
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  []
  [s1]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s1
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s2]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s2
    scalar_type = MinPrincipal
    execute_on = 'TIMESTEP_END'
  []
[]

[Functions]
  [load_func_temporal]
    type = ADParsedFunction
    expression = 'if(t<t0, v0/2/t0*t^2, v0*t - 0.5*v0*t0)'
    symbol_names = 'v0 t0'
    symbol_values = '${v_impact} ${t0}'
  []
  [load_func_spatial]
    type = ADParsedFunction
    # expression = 'if(abs(y) <= 20, 1, 20/abs(y))'
    expression = '1 - pow(abs(y)/50, 1.5)'
  []
  [load_func]
    type = CompositeFunction
    functions = 'load_func_spatial load_func_temporal'
  []
[]

[BCs]
  [xleft]
    type = ADFunctionDirichletBC
    boundary = 1
    variable = disp_x
    function = load_func
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
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
    # parameter_values = '2 0.0'
  []
  # [no_deg]
  #   type = NoDegradation
  #   phase_field = d
  #   expression = 1
  # []
  [strain]
    # type = ADComputePlaneSmallStrain
    # out_of_plane_strain = 'strain_zz'
    type = ADComputeSmallStrain
    displacements = 'disp_x disp_y'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active psie'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    # output_properties = 'stress'
    # outputs = exodus
  []
[]

[Postprocessors]
  [Fx]
    type = NodalSum
    variable = fx
    boundary = load
    # outputs = "csv exodus"
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
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
  # dt = 0.25

  # dtmin = 1e-8
  end_time = ${tf}
  [TimeStepper]
    type = FunctionDT
    function = 'if(t <= ${t0}, 0.25, 0.5)'
  []

  fixed_point_max_its = 10
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
    type = Exodus
    # time_step_interval = 1
    min_simulation_time_interval = 0.5
    additional_execute_on = FAILED
  []
  [csv]
    file_base = './gold/${filebase}'
    type = CSV
  []
  checkpoint = true
  print_linear_residuals = false
  file_base = './out/${filebase}/out'
  time_step_interval = 1
[]