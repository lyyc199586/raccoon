# Dynamic discrete crack by releasing node
# Dynamic J int: J(t) = 

# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
# rho = 2.45e-9 # Mg/mm^3
rho = 2.45e3
Gc = 3e-3 # N/mm -> 3 J/m^2
sigma_ts = 3.08 # MPa, sts and scs from guessing
psic = ${fparse sigma_ts^2/2/E}
# sigma_cs = 9.24
l = 0.65
p = 1

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

[Mesh]
  [gen] #h_c = 1, h_r = 0.25
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 20
    xmin = 0
    xmax = 100
    ymin = 0
    ymax = 20
  []
  [right_sub]
    type = ParsedSubdomainMeshGenerator
    input = gen
    combinatorial_geometry = 'x > 50'
    block_id = 1
    block_name = 'right'
  []
  construct_side_list_from_node_list=true
[]

[UserObjects]
  [moving_circle]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'phi'
    block = 1
    criterion_type = ABOVE
    threshold = 0
    subdomain_id = 1
    moving_boundary_name = moving_boundary
    complement_moving_boundary_name = cmp_moving_boundary
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
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
  [phi]
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
  [phi]
    type = FunctionAux
    variable = phi
    function = moving_circle
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[Functions]
  [moving_circle]
    type = ParsedFunction
    expression = 'x-(50+t)'
  []
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    boundary = top
    function = '${p}'
    factor = -1
  []
  # [ybottom]
  #   type = ADPressure
  #   variable = disp_y
  #   boundary = bottom
  #   function = '${p}'
  #   factor = -1
  # []
  [noncrack]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = 'bottom'
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
  # [degradation]
  #   type = RationalDegradationFunction
  #   property_name = g
  #   phase_field = d
  #   material_property_names = 'Gc psic xi c0 l'
  #   parameter_names = 'p a2 a3 eta'
  #   parameter_values = '2 1 0.0 1e-6'
  # []
  [nodeg]
    type = NoDegradation
    property_name = g 
    phase_field = d
    expression = 1
  []
  [strain]
    type = ADComputeSmallStrain
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
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = top
  []
  [max_disp_y]
    type = NodalExtremeValue
    variable = disp_y
  []
  # [Jint]
  #   type = DynamicPhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'left bottom right top'
  #   density = density
  # []
  # [Jint_over_Gc]
  #   type = ParsedPostprocessor
  #   expression = 'Jint/Gc'
  #   pp_names = 'Jint'
  #   constant_names = 'Gc'
  #   constant_expressions = '${Gc}' 
  # []
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

  # dt = 5e-7
  dt = 0.5
  # dtmin = 1e-8
  # end_time = 50e-6
  end_time = 50

  fixed_point_max_its = 10
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]

[Outputs]
  [exodus]
    type = Exodus
    time_step_interval = 1
    min_simulation_time_interval = 0.5
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