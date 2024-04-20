# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2.45e-9 # Mg/mm^3
Gc = 3e-3 # N/mm -> 3 J/m^2
sigma_ts = 3.08 # MPa, sts and scs from guessing
sigma_cs = 9.24
# sigma_cs = 15

## lch = 3/8*E*Gc/sigma_ts^2 = 3.79
# l = 0.25
# l = 0.5
l = 1
# delta = 5 # haven't tested
refine = 3 # 0.125

# hht parameters
# hht_alpha = -0.25
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

# gamma = 0.5
# beta = 0.25

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};refine=${refine}'
    execute_on = 'TIMESTEP_END'
    clone_parent_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = fracture
    variable = 'd f_nu_var ce_var delta_var'
    source_variable = 'd f_nu_var ce_var delta_var'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = fracture
    # variable = 'disp_x disp_y strain_zz psie_active'
    # source_variable = 'disp_x disp_y strain_zz psie_active'
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
  [pp_transfer_1]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = 'Psi_f'
    to_postprocessor = 'fracture_energy'
    reduction_type = average
  []
  [pp_transfer_2]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = ce_int
    to_postprocessor = ce_int
    reduction_type = average
  []
  [pp_transfer_3]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = Psi_nuc
    to_postprocessor = nucleation_energy
    reduction_type = average
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
  cycles_per_step = ${refine}
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
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
      # markers = 'damage_marker strength_marker'
      markers = 'damage_marker'
    []
  []
[]

[Variables]
  [disp_x]
    # initial_from_file_var = 'disp_x'
    # initial_from_file_timestep = LATEST
  []
  [disp_y]
    # initial_from_file_var = 'disp_y'
    # initial_from_file_timestep = LATEST
  []
  # [strain_zz]
  #   # initial_from_file_var = 'strain_zz'
  #   # initial_from_file_timestep = LATEST
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
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=0&x<=50,1,0)'
    # []
  []
  [ce_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [delta_var]
    order = CONSTANT
    family = MONOMIAL
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
  [s3]
    order = CONSTANT
    family = MONOMIAL
  []
  [s11]
    order = CONSTANT
    family = MONOMIAL
  []
  [s22]
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
  [w_ext]
  []
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
  [s11]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = s11
    index_i = 0
    index_j = 0
    execute_on = 'TIMESTEP_END'
  []
  [s22]
    type = ADRankTwoAux
    rank_two_tensor = stress
    variable = s22
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
  [quadrant]
    type = ParsedAux
    variable = f_quadrant_1
    coupled_variables = 's11 s22'
    expression = 'if(s11>=0, if(s22>=0, 1, 4), if(s22>=0, 2, 3))'
  []
  [quadrant2]
    type = ParsedAux
    variable = f_quadrant_2
    coupled_variables = 's1 s3'
    expression = 'if(s1>=0, if(s3>=0, 1, 4), if(s3>=0, 2, 3))'
  []
  [work]
    type = ParsedAux
    variable = w_ext
    # expression = 'disp_y^2/sqrt(disp_x^2 + disp_y^2) + disp_x^2/sqrt(disp_x^2 + disp_y^2)'
    expression = 'if(x > 0.5, if(x < 99.5, abs(disp_y), abs(disp_y)/2), abs(disp_y)/2)'
    coupled_variables = 'disp_y'
    boundary = 'top bottom'
    use_xyzt = true
  []
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    boundary = top
    factor = -1
  []
  [ybottom]
    type = ADPressure
    variable = disp_y
    boundary = bottom
    factor = -1
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
    boundary = top
    # outputs = "csv exodus"
  []
  [max_disp_y]
    type = NodalExtremeValue
    variable = disp_y
    # outputs = "csv exodus"
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    outputs = "csv exodus"
  []
  [fracture_energy]
    type = Receiver
    # outputs = "csv"
  []
  [ce_int]
    type = Receiver
    # outputs = "csv"
  []
  [nucleation_energy]
    type = Receiver
    # outputs = "csv"
  []
  [kinetic_energy]
    type = KineticEnergy
    # outputs = "csv"
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
    # outputs = "csv"
  []
  [external_work]
    type = ExternalWork
    boundary = 'top bottom'
    forces = 'fx fy'
    # outputs = "csv"
  []
  [preset_ext_work]
    type = SideIntegralVariablePostprocessor
    variable = w_ext
    boundary = "top bottom"
    # execute_on = 'initial timestep_end'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
  #                       '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
  #                       '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
  #                       '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'asm'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8
  nl_max_its = 200

  dt = 5e-7
  # dtmin = 1e-8
  end_time = 100e-6

  # restart
  # start_time = 80e-6
  # end_time = 120e-6

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-8
  # fixed_point_abs_tol = 1e-10
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  # [TimeIntegrator]
  #   type = NewmarkBeta
  #   # gamma = '${fparse 5/6}'
  #   # beta = '${fparse 4/9}'
  # []
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
    minimum_time_interval = 5e-7
  []
  checkpoint = true
  print_linear_residuals = false
  # file_base = './out/dyn_br_nuc22_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}_plane_strain/dyn_br_nuc22_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  file_base = './out/dyn_br_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}_plain_strain/dyn_br_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}'
  interval = 1
  [csv]
    # file_base = './gold/dyn_br_nuc22_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}_plane_strain'
    file_base = './gold/dyn_br_nuc24_ts${sigma_ts}_cs${sigma_cs}_l${l}_plain_strain'
    type = CSV
  []
[]
