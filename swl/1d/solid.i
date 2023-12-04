# Begostone
E = 0.02735
nu = 0
Gc = 21.88e-9
l = 0.1 # h = 0.02
psic = 7.0e-9
# k = 1e-09
rho_s = 1.995e-3

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'

[MultiApps]
  [acoustic]
    type = TransientMultiApp
    execute_on = 'TIMESTEP_END'
    input_files = 'fluid.i'
    # cli_args = 'SD=${SD};p_max=${p_max}'
    # clone_parent_mesh = true
  []
  [damage]
    type = TransientMultiApp
    execute_on = TIMESTEP_END
    input_files = damage.i
    cli_args = 'Gc=${Gc};l=${l};psic=${psic}'
    # clone_parent_mesh = true
  []
[]

[Transfers]
  [from_p]
    type = MultiAppNearestNodeTransfer
    from_multi_app = acoustic
    source_variable = 'p'
    variable = 'pre_wave'
    source_boundary = 'right'
    target_boundary = 'left'
    execute_on = 'TIMESTEP_BEGIN'
  []
  [to_p]
    type = MultiAppNearestNodeTransfer
    to_multi_app = acoustic
    source_variable = 'accel_x'
    variable = 'accel_x_in'
    source_boundary = 'left' # from left of solid
    target_boundary = 'right' # to right of fluid
    execute_on = 'TIMESTEP_END'
  []
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = damage
    source_variable = d
    variable = d
    execute_on = TIMESTEP_BEGIN
  []
  [to_d]
    type = MultiAppCopyTransfer
    to_multi_app = damage
    source_variable = psie_active
    variable = psie_active
    execute_on = TIMESTEP_END
  []
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    # nx = 200
    # ny = 50
    nx = 400
    ny = 50
    xmin = 2
    xmax = 4
    ymin = 0
    ymax = 0.5
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  # gamma = '${fparse 5/6}'
  # beta = '${fparse 4/9}'
  # eta = 19.63
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [d]
  []
  [bounds_dummy]
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [pre_wave]
  []
  [accel_x]
  []
  [vel_x]
  []
  [accel_y]
  []
  [vel_y]
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    component = 0
    variable = disp_x
    # alpha = 0.11
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    component = 1
    variable = disp_y
    # alpha = 0.11
  []
  [inertia_x]
    type = InertialForce
    variable = 'disp_x'
    # velocity = vel_x
    # acceleration = accel_x
  []
  [inertia_y]
    type = InertialForce
    variable = 'disp_y'
    # velocity = vel_y
    # acceleration = accel_y
  []
[]

[AuxKernels]
  [stress_xx]
    type = ADRankTwoAux
    variable = 'stress_xx'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  []
  [psie_active]
    type = ADMaterialRealAux
    property = 'psie_active'
    variable = 'psie_active'
    execute_on = 'TIMESTEP_END'
  []
[]

[BCs]
  [left_p_in]
    type = CoupledPressureBC
    variable = 'disp_x'
    boundary = left
    pressure = 'pre_wave'
    component = 0
  []
[]

[Materials]
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = ${rho_s}
  []
  [ad_density]
    type = ADGenericConstantMaterial
    prop_names = 'ad_density'
    prop_values = ${rho_s}
  []
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'K G l Gc psic'
    prop_values = '${K} ${G} ${l} ${Gc} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1.0 0.0 1e-3'
  []
  # [no_d]
  #   type = NoDegradation
  #   f_name = g
  #   function = 1
  #   phase_field = d
  # []
  [strain]
    type = ADComputeSmallStrain
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    output_properties = 'psie_active'
    # outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    # type = ADComputeLinearElasticStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
[]

[VectorPostprocessors]
  [s]
    type = LineValueSampler
    variable = 'stress_xx psie_active d'
    start_point = '2 0 0'
    end_point = '4 0 0'
    num_points = 200
    sort_by = x
    outputs = vpp
  []
[]

[Postprocessors]
  [max_stress_xx]
    type = ElementExtremeValue
    variable = stress_xx
    outputs = pp
  []
  [min_stress_xx]
    type = ElementExtremeValue
    variable = stress_xx
    value_type = min
    outputs = pp
  []
  [max_d]
    type = NodalExtremeValue
    variable = d
    outputs = pp
  []
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
    # solve_type = consistent
  []
  end_time = 2.2
  dt = 0.5e-3
  # dt = 0.25e-3
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 50
    file_base = './out/solid_h0.005'
  []
  [vpp]
    type = CSV
    interval = 10
    file_base = './out/vpp/line_h0.005'
  []
  [pp]
    type = CSV
    interval = 10
    file_base = './out/pp/max_value_h0.005'
  []
[]
