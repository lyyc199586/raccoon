# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
# rho = 2.45e-9 # Mg/mm^3
rho = 2450
Gc = 3e-3 # N/mm -> 3 J/m^2
# sigma_ts = 3.08 # MPa, sts and scs from guessing
# sigma_cs = 9.24
# sigma_ts = 4.75
sigma_ts = 5.5
sigma_cs = 18
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# lch = 3/8*E*Gc/sigma_ts^2 = 3.79 lch/5 = 0.75
# l: 1, 0.75, 0.5 mm
# l = 0.625
l = 0.375

refine = 4 # 0.125
u0 = 0.0015
Tp = 20
Tf = 50

#
filename = 'straight_with_K_u${u0}_l${l}_rf${refine}_rho${rho}_sts${sigma_ts}_tp${Tp}_tf${Tf}/nuc24'

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_cs=${sigma_cs};sigma_ts=${sigma_ts};'
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
    variable = 'disp_x disp_y psie_active k_var'
    source_variable = 'disp_x disp_y psie_active k_var'
  []
  [pp_transfer]
    type = MultiAppPostprocessorTransfer
    from_multi_app = fracture
    from_postprocessor = 'Psi_f'
    to_postprocessor = 'fracture_energy'
    reduction_type = average
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = false
[]

[Mesh]
  [gen] #h_c = 1, h_r = 0.25
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 40
    xmin = 0
    xmax = 40
    ymin = -20
    ymax = 20
  []
  [sub_upper]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x < 20 & y > 0'
    block_id = 1
  []
  [sub_lower]
    type = ParsedSubdomainMeshGenerator
    input = sub_upper
    combinatorial_geometry = 'x < 20 & y < 0'
    block_id = 2
  []
  [split]
    input = sub_lower
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
  []
  [initial_refine_block]
    input = split
    type = SubdomainBoundingBoxGenerator
    bottom_left = '18.9 -1.1 -0.1'
    top_right = '40.1 1.1 0.1'
    block_id = '3'
  []
  [refine]
    input = initial_refine_block
    type = RefineBlockGenerator
    block = '3'
    refinement = ${refine}
  []
[]

# [Adaptivity]
#   marker = combo_marker
#   max_h_level = ${refine}
#   initial_marker = initial
#   initial_steps = ${refine}
#   cycles_per_step = ${refine}
#   [Markers]
#     [damage_marker]
#       type = ValueRangeMarker
#       variable = d
#       lower_bound = 0.01
#       upper_bound = 1
#     []
#     [strength_marker]
#       type = ValueRangeMarker
#       variable = f_nu_var
#       lower_bound = -1e-4
#       upper_bound = 1e-4
#     []
#     [initial]
#       type = BoxMarker
#       bottom_left = '48.9 -1.1 0'
#       top_right = '51.1 1.1 0'
#       inside = REFINE
#       outside = DONT_MARK
#     []
#     [combo_marker]
#       type = ComboMarker
#       markers = 'damage_marker strength_marker initial'
#     []
#   []
# []

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
  [vel_z]
  []
  [fx]
  []
  [fy]
  []
  [d]
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
  [k_var]
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
  [kinetic_energy_aux]
    type = ADKineticEnergyAux
    variable = k_var
    newmark_velocity_x = vel_x
    newmark_velocity_y = vel_y
    newmark_velocity_z = vel_z
    density = density
  []
[]

[Functions]
  [top_func]
    type = PiecewiseLinear
    x = '0 ${Tp} ${Tf}'
    y = '0 ${u0} ${u0}'
  []
  [bottom_func]
    type = PiecewiseLinear
    x = '0 ${Tp} ${Tf}'
    y = '0 -${u0} -${u0}'
  []
  # [top_func]
  #   type = ADParsedFunction
  #   expression = '1e-6*t^2'
  # []
  # [bottom_func]
  #   type = ADParsedFunction
  #   expression = '-1e-6*t^2'
  # []
[]

[BCs]
  [ytop]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top
    function = top_func
    # function = ${u0}
  []
  [ybottom]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bottom_func
    # function = -${u0}
  []
  # [xtop]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = top
  #   value = 0
  # []
  # [xbottom]
  #   type = ADDirichletBC
  #   variable = disp_x
  #   boundary = bottom
  #   value = 0
  # []
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
    parameter_values = '2 1e-5'
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
    decomposition = NONE
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

[Postprocessors]
  [Fy_top]
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
  [fracture_energy]
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
  []
  # [preset_ext_work]
  #   type = SideIntegralVariablePostprocessor
  #   variable = w_ext
  #   boundary = "top bottom"
  #   # execute_on = 'initial timestep_end'
  # []
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
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg       '
  automatic_scaling = true
  # line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8
  nl_max_its = 200

  # dt = 0.5e-7
  [TimeStepper]
    type = FunctionDT
    function = 'if(t < ${Tp}, 0.5, 0.1)'
  []
  # dtmin = 1e-8
  end_time = ${Tf}

  # restart
  # start_time = 80e-6
  # end_time = 120e-6

  fixed_point_max_its = 10
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  # fixed_point_rel_tol = 1e-4
  # fixed_point_abs_tol = 1e-6
[]

[Outputs]
  [exodus]
    type = Exodus
    min_simulation_time_interval = 0.5
  []
  checkpoint = true
  print_linear_residuals = false
  file_base = './out/${filename}'
  time_step_interval = 1
  [csv]
    file_base = './gold/${filename}'
    type = CSV
  []
[]