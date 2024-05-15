# energy based tip traking: track maximum psie

# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2.45e-9 # Mg/mm^3
Gc = 3e-3 # N/mm -> 3 J/m^2
sigma_ts = 3.08 # MPa, sts and scs from guessing
psic = ${fparse sigma_ts^2/2/E}
# sigma_cs = 9.24
p = 1

## lch = 3/8*E*Gc/sigma_ts^2 = 3.79
l = 0.75
refine = 3 # 0.125

# hht parameters
# hht_alpha = -0.25
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};refine=${refine}'
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
  use_displaced_mesh = true
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
      bottom_left = '47.9 -2.1 0'
      top_right = '52.1 2.1 0'
      inside = REFINE
      outside = DONT_MARK
    []
    [combo_marker]
      type = ComboMarker
      markers = 'damage_marker initial'
    []
  []
[]

# [UserObjects]
#   [tip]
#     type = CoupledVarThresholdElementSubdomainModifier
#     coupled_var = 
#   []
# []

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
  [fx]
  []
  [fy]
  []
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=49.5&x<=50.5,1,0)'
    []
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
  [f_quadrant_1]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_quadrant_2]
    order = CONSTANT
    family = MONOMIAL
  []
  # [psie_ratio] # psie/psie_max
  # []
[]


[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    save_in = fx
    component = 0
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
    execute_on = timestep_end
  []
  [vel_x] 
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
  # [quadrant]
  #   type = ParsedAux
  #   variable = f_quadrant_1
  #   coupled_variables = 's11 s22'
  #   expression = 'if(s11>=0, if(s22>=0, 1, 4), if(s22>=0, 2, 3))'
  # []
  # [quadrant2]
  #   type = ParsedAux
  #   variable = f_quadrant_2
  #   coupled_variables = 's1 s3'
  #   expression = 'if(s1>=0, if(s3>=0, 1, 4), if(s3>=0, 2, 3))'
  # []
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    boundary = top
    function = '${p}'
    factor = -1
  []
  [ybottom]
    type = ADPressure
    variable = disp_y
    boundary = bottom
    function = '${p}'
    factor = -1
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
  [crack_surface_density]
    type = CrackSurfaceDensity
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
    # type = ADComputePlaneSmallStrain
    type = ADComputeSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active psie psie_intact'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
  [s1_mat]
    type = ADParsedMaterial
    property_name = s1_mat 
    coupled_variables = s1
    expression = 's1'
  []
  [psie_ratio_mat]
    type = ADParsedMaterial
    property_name = psie_ratio_mat
    material_property_names = 'psie'
    postprocessor_names = 'max_psie'
    expression = 'if(psie/max_psie>0.9,1,0)'
    outputs = exodus
  []
  [s1_ratio_mat]
    type = ADParsedMaterial
    property_name = s1_ratio_mat
    material_property_names = 's1_mat'
    postprocessor_names = 'max_s1'
    expression = 'if(s1_mat/max_s1>0.9,1,0)'
    outputs = exodus
  []
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = top
    # outputs = "csv exodus"
  []
  [max_disp_y]
    type = NodalExtremeValue
    variable = disp_y
    # outputs = "csv exodus"
  []
  [max_psie]
    type = ADElementExtremeMaterialProperty
    mat_prop = psie
    value_type = max
  []
  [max_s1]
    type = ADElementExtremeMaterialProperty
    mat_prop = s1_mat
    value_type = max 
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    outputs = "csv exodus"
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
                        '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
                        '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
                        '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  nl_max_its = 200

  dt = 5e-7
  # dtmin = 1e-8
  end_time = 100e-6

  fixed_point_max_its = 10
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
    type = Exodus
    time_step_interval = 1
    min_simulation_time_interval = 5e-7
  []
  checkpoint = true
  print_linear_residuals = false
  file_base = './out/dyn_br_p${p}_l${l}/dyn_br_p${p}_l${l}'
  time_step_interval = 1
  [csv]
    file_base = './gold/dyn_br_p${p}_l${l}'
    type = CSV
  []
[]



