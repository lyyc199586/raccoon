# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2450
Gc = 3e-3 # N/mm -> 3 J/m^2
# sigma_ts = 3.08 # MPa, sts and scs from guessing
# sigma_cs = 9.24
sigma_ts = 8
# sigma_cs = 30
psic = ${fparse sigma_ts^2/2/E}

u0 = 0.0025
tf = 70
h = 1
l = 0.625
ref = 3

# hht parameters
hht_alpha = -0.3
# hht_alpha = 0
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'


filebase = coh_free_u${u0}_ts${sigma_ts}_l${l}_h${h}_rf${ref}

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = frac_coh.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};'
                'ref=${ref}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  # use_displaced_mesh = true
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './pre/pre_u${u0}_h${h}.e'
    use_for_exodus_restart = true
  []
[]

[Adaptivity]
  marker = combo_marker
  max_h_level = ${ref}
  initial_marker = initial_marker
  initial_steps = ${ref}
  cycles_per_step = ${ref}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.001
      upper_bound = 1
    []
    [psic_marker]
      type = ValueThresholdMarker
      variable = psie_active
      refine = '${fparse 0.9*psic}'
    []
    [initial_marker]
      type = BoxMarker
      bottom_left = '9.9 -1.1 -0.1'
      top_right = '11.1 1.1 0.1'
      inside = REFINE
      outside = DONT_MARK
    []
    [combo_marker]
      type = ComboMarker
      markers = 'initial_marker damage_marker psic_marker'
    []
  []
[]

[Variables]
  [disp_x]
    initial_from_file_var = 'disp_x'
    initial_from_file_timestep = LATEST
  []
  [disp_y]
    initial_from_file_var = 'disp_y'
    initial_from_file_timestep = LATEST
  []
  # [strain_zz]
  #   initial_from_file_var = 'strain_zz'
  #   initial_from_file_timestep = LATEST
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
  [fx]
  []
  [fy]
  []
  [d]
  []
  [vms]
    order = CONSTANT
    family = MONOMIAL
  []
  [hydrostatic]
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
  [hydrostatic]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hydrostatic
    scalar_type = Hydrostatic
    execute_on = 'TIMESTEP_END'
  []
  [vms]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = vms
    scalar_type = VonMisesStress
    execute_on = 'TIMESTEP_END'
  []
[]

[BCs]
  [ytop]
    type = ADDirichletBC
    variable = disp_y
    boundary = top
    value = ${u0}
    # value = 0
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = bottom
    value = -${u0}
    # value = 0
  []
  [xtop]
    type = ADDirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
  [xbottom]
    type = ADDirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  # [nodeg]
  #   type = NoDegradation
  #   property_name = g
  #   phase_field = d
  # []
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0.0 1e-6'
  []
  [strain]
    # type = ADComputePlaneSmallStrain
    type = ADComputeSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    output_properties = 'psie_active psie'
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

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist     '
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true

  # line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  nl_max_its = 100

  # dt = ${fparse t0*0.1}
  dt = 0.25
  # dt = ${fparse t0*0.005}
  # dt = ${t0}
  end_time = ${tf}

  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  # num_steps = 4
[]

[Outputs]
  [exodus]
    type = Exodus
    # interval = 5
    time_step_interval = 1
    min_simulation_time_interval = 0.25
  []
  # checkpoint = true
  print_linear_residuals = false
  file_base = './out/${filebase}/coh'
  # interval = 1
  time_step_interval = 1
[]