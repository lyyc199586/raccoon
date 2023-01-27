[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/2d/inner_h0.01.msh'
  []
[]

[Problem]
  coord_type = RZ
[]

[GlobalParams]
  displacements = 'disp_r disp_z'
[]

[MultiApps]
  [acoustic]
    type = TransientMultiApp
    execute_on = 'TIMESTEP_END'
    input_files = 'rz_acoustic.i'
    cli_args = 'SD=${SD};p_max=${p_max}'
  []
[]

[Transfers]
  [from_p]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = 'acoustic'
    source_variable = 'p'
    variable = 'pre_wave'
    source_boundary = 'inner_BC'
    target_boundary = 'outer_BC'
    execute_on = 'TIMESTEP_END'
  []
[]

[Variables]
  [disp_r]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [d]
  []
  [pre_wave]
  []
  [stress_h]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_VonMises]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_rr]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [bounds_dummy]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
    # order = SECOND
    # family = L2_LAGRANGE
  []
  # [alpha_bar]
  #   order = CONSTANT
  #   # order = SECOND
  #   family = MONOMIAL
  # []
  # [f_alpha]
  #   order = CONSTANT
  #   # order = SECOND
  #   family = MONOMIAL
  # []
  # [vel_r]
  # []
  # [vel_z]
  # []
  # [accel_r]
  # []
  # [accel_z]
  # []
[]

[Kernels]
  [stress_rr]
    type = ADStressDivergenceRZTensors
    component = 0
    variable = disp_r
  []
  [stress_zz]
    type = ADStressDivergenceRZTensors
    component = 1
    variable = disp_z
  []
  [inertia_rr]
    type = InertialForce
    variable = 'disp_r'
    # velocity = 'vel_r'
    # acceleration = 'accel_r'
    # beta = 0.25
    # gamma = 0.5
  []
  [inertia_zz]
    type = InertialForce
    variable = 'disp_z'
    # velocity = 'vel_z'
    # acceleration = 'accel_z'
    # beta = 0.25
    # gamma = 0.5
  []
[]

[AuxKernels]
  [stress_h]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 'stress_h'
    scalar_type = Hydrostatic
    execute_on = 'TIMESTEP_END'
  []
  [stress_VonMises]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 'stress_VonMises'
    scalar_type = VonMisesStress
    execute_on = 'TIMESTEP_END'
  []
  [stress_rr]
    type = ADRankTwoAux
    variable = 'stress_rr'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  []
  [stress_zz]
    type = ADRankTwoAux
    variable = 'stress_zz'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
  []
  [psie_active]
    type = ADMaterialRealAux
    property = 'psie_active'
    variable = 'psie_active'
    execute_on = 'TIMESTEP_END'
  []
  # [accel_r]
  #   type = NewmarkAccelAux
  #   variable = accel_r
  #   displacement = disp_r
  #   velocity = vel_r
  #   beta = 0.25
  #   execute_on = timestep_end
  # []
  # [vel_r]
  #   type = NewmarkVelAux
  #   variable = vel_r
  #   acceleration = accel_r
  #   gamma = 0.5
  #   execute_on = timestep_end
  # []
  # [accel_z]
  #   type = NewmarkAccelAux
  #   variable = accel_z
  #   displacement = disp_z
  #   velocity = vel_z
  #   beta = 0.25
  #   execute_on = timestep_end
  # []
  # [vel_z]
  #   type = NewmarkVelAux
  #   variable = vel_z
  #   acceleration = accel_z
  #   gamma = 0.5
  #   execute_on = timestep_end
  # []
  # [f_alpha]
  #   type = ADMaterialRealAux
  #   property = 'f_alpha'
  #   variable = 'f_alpha'
  #   execute_on = 'TIMESTEP_END'
  # []
  # [alpha_bar]
  #   type = ADMaterialRealAux
  #   property = 'alpha_bar'
  #   variable = 'alpha_bar'
  #   execute_on = 'TIMESTEP_END'
  # []
  # [./SimpsonsTimeIntegrator]
  #   type = VariableTimeIntegrationAux
  #   variable_to_integrate = u
  #   variable = v_simpson
  #   order 
[]

[BCs]
  [curved_r]
    type = CoupledPressureBC
    variable = 'disp_r'
    boundary = 'curved'
    pressure = 'pre_wave'
    component = 0
  []
  [curved_z]
    type = CoupledPressureBC
    variable = 'disp_z'
    boundary = 'curved'
    pressure = 'pre_wave'
    component = 1
  []
  [top_z]
    type = CoupledPressureBC
    variable = 'disp_z'
    boundary = 'top'
    pressure = 'pre_wave'
    component = 1
  []
  [bottom_z]
    type = CoupledPressureBC
    variable = 'disp_z'
    boundary = 'bottom'
    pressure = 'pre_wave'
    component = 1
  []
  [axial_x]
    type = DirichletBC
    variable = 'disp_r'
    boundary = 'axial'
    value = 0
  []
[]

# [Materials]
#   [./elasticity]
#     type = ADComputeIsotropicElasticityTensor
#     poissons_ratio = 0.3
#     youngs_modulus = 1e10
#   [../]
#   [./strain]
#     type = ADComputeAxisymmetricRZSmallStrain
#   [../]
#   [./stress]
#     type = ADComputeLinearElasticStress
#   [../]
# []

[Postprocessors]
  [w_ext_top]
    type = ExternalWork
    displacements = 'disp_z'
    forces = pre_wave
    boundary = top
  []
  [w_ext_bottom]
    type = ExternalWork
    displacements = 'disp_z'
    forces = pre_wave
    boundary = bottom
  []
  [w_ext_curved]
    type = ExternalWork
    displacements = 'disp_r'
    forces = pre_wave
    boundary = curved
  []
  [kinetic_energy]
    type = KineticEnergy
    displacements = 'disp_r disp_z'
    density = ad_density
  []
  [strain_energy]
    type = ElementIntegralVariablePostprocessor
    variable = psie_active
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
    # function = '(1-d)^p/((1-d)^p+(Gc_deg/psic_deg*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta'
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1.0 0.0 1e-3'
  []
  [strain]
    type = ADComputeAxisymmetricRZSmallStrain
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = SPECTRAL
    output_properties = 'elastic_strain psie_active'
    # outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    # type = ADComputeLinearElasticStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
  []
  # [Gc_deg]
  #   type = ADParsedMaterial
  #   f_name = Gc_deg
  #   function = 'f_alpha*Gc'
  #   material_property_names = 'f_alpha Gc'
  # []
  # [psic_deg]
  #   type = ADParsedMaterial
  #   f_name = psic_deg
  #   function = 'f_alpha*psic'
  #   material_property_names = 'f_alpha psic'
  # []
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
    # solve_type = consistent
  []
  # [TimeIntegrator]
  #   type = NewmarkBeta
  #   beta = 0.25
  #   gamma = 0.5
  # []
  end_time = 2.1
  # dt = 0.75e-3
  dt = 1.5e-3
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 50
    # interval = 25
    file_base = solid-1
  []
  [console]
    type = Console
    outlier_variable_norms = false
  []
  [csv]
    type = CSV
    delimiter = ','
    file_base = 'strain_energy'
  []
  # [my_checkpoint]
  #   type = Checkpoint
  #   num_files = 2
  #   interval = 25
  # []
[]
