[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 50
    xmin = 2
    xmax = 3
    ymin = 0
    ymax = 1
  []
  [gen2]
    type = ExtraNodesetGenerator
    input = gmg
    new_boundary = fix_point
    coord = '2.5 0'
  []
[]

[Problem]
  # coord_type = RZ
  coord_type = XYZ
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[MultiApps]
  [acoustic]
    type = TransientMultiApp
    execute_on = 'TIMESTEP_END'
    input_files = 'acoustic.i'
    cli_args = 'p_max=${p_max}'
  []
[]

[Transfers]
  [from_p]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = 'acoustic'
    source_variable = 'p'
    variable = 'pre_wave'
    source_boundary = 'right'
    target_boundary = 'left'
    execute_on = 'TIMESTEP_END'
  []
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
  [pre_wave]
  []
  # [./stress_h]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  [stress_VonMises]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [bounds_dummy]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [stress_xx]
    type = ADStressDivergenceTensors
    component = 0
    variable = disp_x
  []
  [stress_yy]
    type = ADStressDivergenceTensors
    component = 1
    variable = disp_y
  []
  [inertia_xx]
    type = InertialForce
    variable = 'disp_x'
  []
  [inertia_yy]
    type = InertialForce
    variable = 'disp_y'
  []
[]

[AuxKernels]
  # [./stress_h]
  #   type = ADRankTwoScalarAux
  #   rank_two_tensor = 'stress'
  #   variable = 'stress_h'
  #   scalar_type = Hydrostatic
  #   execute_on = 'TIMESTEP_END'
  # [../]
  [stress_VonMises]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 'stress_VonMises'
    scalar_type = VonMisesStress
    execute_on = 'TIMESTEP_END'
  []
  [stress_xx]
    type = ADRankTwoAux
    variable = 'stress_xx'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  []
  [stress_yy]
    type = ADRankTwoAux
    variable = 'stress_yy'
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
[]

[BCs]
  [left_x]
    type = CoupledPressureBC
    variable = 'disp_x'
    boundary = 'left'
    pressure = 'pre_wave'
    component = 0
  []
  # [fix_x]
  #   type = DirichletBC
  #   variable = 'disp_x'
  #   boundary = 'fix_point'
  #   value = 0
  # []
  # [fix_y]
  #   type = DirichletBC
  #   variable = 'disp_y'
  #   boundary = 'fix_point'
  #   value = 0
  # []
  # [./curved_z]
  #   type = CoupledPressureBC
  #   variable = 'disp_z'
  #   boundary = 'curved'
  #   pressure = 'pre_wave'
  #   component = 1
  # [../]
  # [./top_z]
  #   type = CoupledPressureBC
  #   variable = 'disp_z'
  #   boundary = 'top'
  #   pressure = 'pre_wave'
  #   component = 1
  # [../]
  # [./bottom_z]
  #   type = CoupledPressureBC
  #   variable = 'disp_z'
  #   boundary = 'bottom'
  #   pressure = 'pre_wave'
  #   component = 1
  # [../]
  # [./axial_x]
  #   type = DirichletBC
  #   variable = 'disp_r'
  #   boundary = 'axial'
  #   value = 0
  # [../]
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
  [strain]
    # type = ADComputeAxisymmetricRZSmallStrain
    type = ADComputeSmallStrain
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
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []
  # end_time = 2.4
  end_time = 2.1
  dt = 0.75e-3
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 50
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
[]
