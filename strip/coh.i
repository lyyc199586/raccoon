# geometry [0, 100]*[-20,20], crack at [0, 50]*{y=0}
# soda-lime glass, provided in Table 3, wu's EFM2020
# unit: MPa, mm, us 
E = 72e3
nu = 0.22
rho = 2440
Gc = 3.08e-3
sigma_ts = 28.6
psic = ${fparse sigma_ts^2/2/E}

# cr = 3192 m/s
# cd = 5800 m/s
# lch = E*Gc/sigma_ts^2 = 0.33 mm

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

l = 0.25 # for h = 0.0625 (1/2^4)
refine = 4
# p = 0.5
p = 3

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = true
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = coh_pf.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};refine=${refine}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
    # variable = 'disp_x disp_y psie_active'
    # source_variable = 'disp_x disp_y psie_active'
  []
  [pp_transfer]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = Psi_f
    to_postprocessor = fracture_energy
    reduction_type = average
  []
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
    add_interface_on_two_sides = true
  []
[]

[Adaptivity]
  marker = combo_marker
  max_h_level = ${refine}
  initial_marker = initial
  initial_steps = ${refine}
  cycles_per_step = ${refine}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [psic_marker]
      type = ValueThresholdMarker
      variable = psie_active
      refine = 0.00075
    []
    [initial]
      type = BoxMarker
      bottom_left = '48.9 -1.1 0'
      top_right = '51.1 1.1 0'
      inside = REFINE
      outside = DONT_MARK
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker initial'
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
  [s1]
    order = CONSTANT
    family = MONOMIAL
  []
  [s2]
    order = CONSTANT
    family = MONOMIAL
  []
  [s3]
    order = CONSTANT
    family = MONOMIAL
  []
  [kinetic_energy_var]
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
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
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
    scalar_type = MidPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s3]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s3
    scalar_type = MinPrincipal
    execute_on = 'TIMESTEP_END'
  []
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    boundary = 4
    function = '${p}'
    factor = 1
  []
  [ybottom]
    type = ADPressure
    variable = disp_y
    boundary = 5
    function = '${p}'
    factor = 1
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
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0.0 1e-6'
  []
  [strain]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    output_properties = 'total_strain'
    outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    output_properties = 'psie_active psie psie_intact'
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
    boundary = 4
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
  []
  [max_disp_y]
    type = NodalExtremeValue
    variable = disp_y
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    # boundary = '0 1 2 3 4 5'
  []
  [DJint]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    density = density
    boundary = 'left bottom right top'
    # boundary = '0 1 2 3 4 5'
  []
  [fracture_energy]
    type = Receiver
    execute_on = 'timestep_end'
  []
  [kinetic_energy]
    type = KineticEnergy
    execute_on = 'timestep_end'
    # implicit = false
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
    execute_on = 'timestep_end'
  []
  [external_work]
    type = ExternalWork
    # boundary = 'top bottom'
    boundary = '4 5'
    forces = 'fx fy'
    execute_on = 'initial timestep_end'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = 0.25
  # end_time = 120
  end_time = 45

  fixed_point_max_its = 20
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  # num_steps = 10
[]

[Outputs]
  [exodus]
    type = Exodus
    min_simulation_time_interval = 0.25
  []
  print_linear_residuals = false
  file_base = './out/strip_coh_p${p}_l${l}/strip'
  time_step_interval = 1
  [csv]
    file_base = './gold/strip_coh_p${p}_l${l}'
    type = CSV
  []
[]