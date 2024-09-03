# crack from pressurized hole
# unit: ug, mm, us -> N, MPa, N/mm

## BegoStone
E = 6.16e3
rho = 1.995e3

nu = 0.3
sigma_ts = 10
# sigma_cs = 22.27
sigma_cs = 50
sigma_hs = '${fparse 2/3*sigma_ts*sigma_cs/(sigma_cs - sigma_ts)}'

Gc = 3.656e-2
l = 0.05 # lch = 3/8*Gc*E/sts/sts = 0.84
refine = 3 # h = 0.1/8

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

T0 = 15
p0 = 60
seed = 2

## hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

filename = 'p${p0}_t${T0}_sts${sigma_ts}_scs${sigma_cs}_l${l}_h0.1_rf${refine}/frag'


[GlobalParams]
  displacements = 'disp_X disp_Y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = False
[]

[Transfers]
  [from_patches]
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = patches
    variable = 'sigma_ts sigma_hs'
    source_variable = 'sigma_ts sigma_hs'
    execute_on = 'INITIAL'
  []
  [from_d]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = fracture
    variable = 'd ce f_nu delta'
    source_variable = 'd ce f_nu delta'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    # type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = fracture
    variable = 'psie_active disp_X disp_Y sigma_ts sigma_hs'
    source_variable = 'psie_active disp_X disp_Y sigma_ts sigma_hs'
  []
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};refine=${refine}'
    execute_on = TIMESTEP_END
  []
  [patches]
    type = FullSolveMultiApp
    input_files = patches.i
    # cli_args = 'seed=${seed};E=${E}'
    cli_args = 'seed=${seed};sigma_ts=${sigma_ts};sigma_hs=${sigma_hs}'
    execute_on = 'INITIAL'
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/annulus_r0.245_h0.1.msh'
  []
[]

[Adaptivity]
  marker = combo
  initial_marker = inner_bnd
  initial_steps = ${refine}
  max_h_level = ${refine}
  cycles_per_step = 5
  [Markers]
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [inner_bnd]
      type = BoundaryMarker
      mark = REFINE
      next_to = inner
    []
    [combo]
      type = ComboMarker
      markers = 'damage_marker inner_bnd'
    []
  []
[]

[Variables]
  [disp_X]
  []
  [disp_Y]
  []
  # [strain_zz]
  # []
[]

[AuxVariables]
  [d]
  []
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
  [hoop]
    order = CONSTANT
    family = MONOMIAL
  []
  [radial]
    order = CONSTANT
    family = MONOMIAL
  []
  [pressure]
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
  [sigma_ts]
    order = CONSTANT
    family = MONOMIAL
    [InitialCondition]
      type = ConstantIC
      value = ${sigma_ts}
    []
  []
  [sigma_hs]
    order = CONSTANT
    family = MONOMIAL
    [InitialCondition]
      type = ConstantIC
      value = ${sigma_hs}
    []
  []
  # [E]
  #   order = CONSTANT
  #   family = MONOMIAL
  #   [InitialCondition]
  #     type = ConstantIC
  #     value = ${E}
  #   []
  # []
  [ce]
    order = CONSTANT
    family = MONOMIAL
  []
  [delta]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_nu]
    order = CONSTANT
    family = MONOMIAL
  []
  [p_bc_var]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_X
    component = 0
    save_in = fx
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_Y
    component = 1
    save_in = fy
  []
  [inertia_x]
    type = ADInertialForce
    variable = disp_X
    density = density
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_Y
    density = density
    velocity = vel_y
    acceleration = accel_y
  []
  # [plane_stress]
  #   type = ADWeakPlaneStress
  #   variable = 'strain_zz'
  #   # displacements = 'disp_x disp_y'
  # []
[]

[AuxKernels]
  [hoop]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hoop
    scalar_type = HoopStress
  []
  [radial]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = radial
    scalar_type = RadialStress
  []
  [pressure]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = pressure 
    scalar_type = Hydrostatic
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
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_X
    velocity = vel_x
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_Y
    velocity = vel_y
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
  []
  [get_p_mat]
    type = ADMaterialRealAux
    property = p_mat
    variable = p_bc_var
    boundary = inner
  []
[]

[Functions]
  [p_func]
    type = ADParsedFunction
    expression = 'p0*exp(-t/T0)'
    symbol_names = 'p0 T0'
    symbol_values = '${p0} ${T0}'
  []
  # [dts]
  #   type = PiecewiseLinear
  #   x = '0    36e-6 39e-6 40e-6 80e-6'
  #   y = '4e-6 4e-6 1e-6 1e-7 1e-7'
  # []
  # [dts]
  #   type = PiecewiseLinear
  #   x = '0 48 48.5   80'
  #   y = '4 4  0.1  0.1'
  # []
[]

[BCs]
  [pressure_x]
    type = CoupledPressureBC
    boundary = inner
    variable = 'disp_X'
    pressure = p_bc_var
    component = 0
  []
  [pressure_y]
    type = CoupledPressureBC
    boundary = inner
    variable = 'disp_Y'
    pressure = p_bc_var
    component = 1
  []
  [left_x]
    type = ADDirichletBC
    boundary = left
    variable = disp_X
    value = 0
  []
  [bottom_y]
    type = ADDirichletBC
    boundary = bottom 
    variable = disp_Y
    value = 0
  []
[]

[Materials]
  [p_mat]
    type = ADParsedMaterial
    property_name = p_mat
    expression = 'g*p0*exp(-t/T0)'
    # expression = 'p0*exp(-t/T0)'
    coupled_variables = 'd'
    material_property_names = 'g'
    constant_names = 'p0 T0'
    constant_expressions = '${p0} ${T0}'
    extra_symbols = 't'
  []
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  [sigma_ts]
    type = ADParsedMaterial
    property_name = sigma_ts 
    coupled_variables = 'sigma_ts'
    expression = 'sigma_ts'
    # outputs = exodus
  []
  [sigma_hs]
    type = ADParsedMaterial
    property_name = sigma_hs 
    coupled_variables = 'sigma_hs'
    expression = 'sigma_hs'
    # outputs = exodus
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    # expression = (1-d)^p+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
    # parameter_values = '2 0'
  []
  [strain]
    type = ADComputeSmallStrain
    # type = ADComputePlaneSmallStrain
    # out_of_plane_strain = strain_zz
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = SPECTRAL
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
  [Load]
    type = SideIntegralVariablePostprocessor
    boundary = inner
    variable = pressure
  []
  [avg_s1]
    type = SideAverageValue
    boundary = inner
    variable = s1
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  # petsc_options_iname = '-pc_type -ksp_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -sub_pc_factor_shift_type -sub_pc_factor_shift_amount ' 
  # petsc_options_value = 'asm      gmres     200                preonly       lu           1  NONZERO 1e-14  '
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart '
  #                       '-pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_interp_type '
  #                       '-pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_agg_nl '
  #                       '-pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor'
  # petsc_options_value = 'hypre boomeramg 400 0.25 ext+i PMIS 4 2 0.4'
  automatic_scaling = true
  scaling_group_variables = 'disp_X disp_Y'

  # l_abs_tol = 1e-8
  # l_max_its = 200
  # nl_rel_tol = 1e-4
  # nl_abs_tol = 1e-6
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # nl_max_its = 200

  # line_search = none
  # fixed_point_algorithm = 
  fixed_point_max_its = 50
  # disable_fixed_point_residual_norm_check = true
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  # fixed_point_rel_tol = 1e-4
  # fixed_point_abs_tol = 1e-6
  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<50,2,0.05)'
  #   min_dt = 5e-3
  # []
  dt = 0.2
  dtmin = 0.01
  start_time = 0
  end_time = 100
  # num_steps = 1
  # [TimeIntegrator]
  #   type = NewmarkBeta
  # []
  # relaxation_factor = 0.1
[]

[Outputs]
  [exodus]
    type = Exodus 
    min_simulation_time_interval = 0.2
    # execute_on = 'INITIAL TIMESTEP_END FAILED'
  []
  file_base = './out/${filename}'
  checkpoint = true
  [csv]
    file_base = './gold/${filename}'
    type = CSV
  []
[]

[Debug]
  show_var_residual_norms = false
[]