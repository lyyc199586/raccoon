[GlobalParams]
  displacements = 'disp_x disp_y'
[]

# [Problem]
#   coord_type = RZ
# []

[Mesh]
   [./fmg]
     type = FileMeshGenerator
     file = '../mesh/2d/inner.msh'
   [../]
[]

[MultiApps]
  [./acoustic]
    type = TransientMultiApp
    execute_on = 'TIMESTEP_END'
    input_files = 'acoustic-1.i'
  [../]
[]

[Transfers]
  #[./to_accel_x]
  #  type = MultiAppNearestNodeTransfer
  #  direction = to_multiapp
  #  multi_app = 'acoustic'
  #  source_variable = 'accel_x'
  #  variable = 'accel_x'
  #  source_boundary = 'curved'
  #  target_boundary = 'curved'
  #  execute_on = 'TIMESTEP_BEGIN'
  #[../]
  #[./to_accel_y]
  #  type = MultiAppNearestNodeTransfer
  #  direction = to_multiapp
  #  multi_app = 'acoustic'
  #  source_variable = 'accel_y'
  #  variable = 'accel_y'
  #  source_boundary = 'top_bottom'
  #  target_boundary = 'top_bottom'
  #  execute_on = 'TIMESTEP_BEGIN'
  #[../]
  #[./to_accel_z]
  #  type = MultiAppNearestNodeTransfer
  #  direction = to_multiapp
  #  multi_app = 'acoustic'
  #  source_variable = 'accel_z'
  #  variable = 'accel_z'
  #  source_boundary = 'curved'
  #  target_boundary = 'curved'
  #  execute_on = 'TIMESTEP_BEGIN'
  #[../]
  [./from_p]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = 'acoustic'
    source_variable = 'p'
    variable = 'pre_wave'
    source_boundary = 'inner_BC'
    target_boundary = 'outer_BC'
    execute_on = 'TIMESTEP_END'
  [../]
[]

[Variables]
  [./disp_x]
  [../]
  # [./disp_y]
  # [../]
  [./disp_y]
  [../]
[]

[AuxVariables]
  [./d]
  [../]
  #[./accel_x]
  #[../]
  #[./accel_y]
  #[../]
  #[./accel_z]
  #[../]
  [./pre_wave]
  [../]
  [./stress_h]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_VonMises]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  # [./stress_yy]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./bounds_dummy]
  [../]
  [./psie_active]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./solid_x]
     type = ADStressDivergenceTensors
     variable = 'disp_x'
    #  displacements = 'disp_r disp_z'
     component = 0
  [../]
  # [./solid_y]
  #    type = ADStressDivergenceTensors
  #    variable = 'disp_y'
  #    displacements = 'disp_x disp_y disp_z'
  #    component = 1
  # [../]
  [./solid_y]
     type = ADStressDivergenceTensors
     variable = 'disp_y'
    #  displacements = 'disp_r disp_z'
     component = 1
  [../]
  [./inertia_x]
    type = InertialForce
    variable = 'disp_x'
  [../]
  # [./inertia_y]
  #   type = InertialForce
  #   variable = 'disp_y'
  # [../]
  [./inertia_y]
    type = InertialForce
    variable = 'disp_y'
  [../]
[]

[AuxKernels]
  #[./accel_x]
  #  type = ExplicitAccelAux
  #  variable = 'accel_x'
  #  displacement = 'disp_x'
  #  execute_on = 'TIMESTEP_END'
  #[../]
  #[./accel_y]
  #  type = ExplicitAccelAux
  #  variable = 'accel_y'
  #  displacement = 'disp_y'
  #  execute_on = 'TIMESTEP_END'
  #[../]
  #[./accel_z]
  #  type = ExplicitAccelAux
  #  variable = 'accel_z'
  #  displacement = 'disp_z'
  #  execute_on = 'TIMESTEP_END'
  #[../]
  [./stress_h]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 'stress_h'
    scalar_type = Hydrostatic
    execute_on = 'TIMESTEP_END'
  [../]
  [./stress_VonMises]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = 'stress_VonMises'
    scalar_type = VonMisesStress
    execute_on = 'TIMESTEP_END'
  [../]
  [./stress_xx]
    type = ADRankTwoAux
    variable = 'stress_xx'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
    execute_on = 'TIMESTEP_END'
  [../]
  # [./stress_yy]
  #   type = ADRankTwoAux
  #   variable = 'stress_yy'
  #   rank_two_tensor = 'stress'
  #   index_i = 1
  #   index_j = 1
  #   execute_on = 'TIMESTEP_END'
  # [../]
  [./stress_yy]
    type = ADRankTwoAux
    variable = 'stress_yy'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
    execute_on = 'TIMESTEP_END'
  [../]
  [./psie_active]
    type = ADMaterialRealAux
    property = 'psie_active'
    variable = 'psie_active'
    execute_on = 'TIMESTEP_END'
  [../]
[]

[BCs]
  [./curved_x]
    type = CoupledPressureBC
    variable = 'disp_x'
    boundary = 'curved'
    pressure = 'pre_wave'
    component = 0
  [../]
  # [./curved_y]
  #   type = CoupledPressureBC
  #   variable = 'disp_y'
  #   boundary = 'curved'
  #   pressure = 'pre_wave'
  #   component = 1
  # [../]
  [./curved_y]
    type = CoupledPressureBC
    variable = 'disp_y'
    boundary = 'curved'
    pressure = 'pre_wave'
    component = 1
  [../]
  [./top_y]
    type = CoupledPressureBC
    variable = 'disp_y'
    boundary = 'top'
    pressure = 'pre_wave'
    component = 1
  [../]
  [./bottom_y]
    type = CoupledPressureBC
    variable = 'disp_y'
    boundary = 'bottom'
    pressure = 'pre_wave'
    component = 1
  [../]
  [./axial_x]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'axial'
    value = 0
  [../]
  # [./back_z]
  #   type = DirichletBC
  #   variable = 'disp_z'
  #   boundary = 'back'
  #   value = 0
  # [../]
[]

# Bogostone material properties
[Materials]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1.995e-3'
  [../]
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
  [./TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  [../]
  
  end_time = 2.1
  dt = 0.75e-3
[]

[Outputs]
 [./exodus]
   type = Exodus
   interval = 50
   file_base = solid-1
 [../]
 [./console]
   type = Console
   outlier_variable_norms = false
 [../]
[]
