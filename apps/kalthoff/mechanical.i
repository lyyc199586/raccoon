Gc = 22.2
# l = 0.35
l = 1
psic = 7.9
E = 1.9e5
nu = 0.3
rho = 8e-9 # [Mg/mm^3]
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

sigma_ts = 1158 # MPa
# sigma_ts = 1852 # 1.6*1158, 2000
sigma_cs = 5840 # MPa
# sigma_cs = 10340
delta = 4

[GlobalParams]
  displacements = 'disp_x disp_y'
[]
[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = 'fracture.i' # fracture_nucleation
    # cli_args = 'Gc=${Gc};l=${l};psic=${psic}'
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l}'
    execute_on = 'TIMESTEP_END'
  []
[]
[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    source_variable = d
    variable = d
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = 'psie_active ce'
    source_variable = 'psie_active ce'
  []
[]
[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './gold/kal_tri.msh'
  []
[]
[Variables]
  [disp_x]
  []
  [disp_y]
  []
  # [strain_zz]
  # []
[]
[AuxVariables]
  [stress]
    order = CONSTANT
    family = MONOMIAL
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [d]
  []
[]
[AuxKernels]
  [stress]
    type = ADRankTwoScalarAux
    variable = stress
    rank_two_tensor = 'stress'
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [psie_active]
    type = ADMaterialRealAux
    variable = psie_active
    property = 'psie_active'
    execute_on = 'TIMESTEP_END'
  []
[]
[Kernels]
  [inertia_x]
    type = InertialForce
    variable = disp_x
    density = 'reg_density'
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    density = reg_density
  []
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    alpha = '${fparse -1/3}'
    component = 0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    alpha = '${fparse -1/3}'
    component = 1
  []
  # [plane_stress] # added
  #   type = ADWeakPlaneStress
  #   variable = 'strain_zz'
  #   displacements = 'disp_x disp_y'
  # []
[]
[BCs]
  [xdisp]
    type = FunctionDirichletBC
    variable = 'disp_x'
    boundary = 'load'
    function = 'if(t<1e-6, 0.5*1.65e10*t*t, 1.65e4*t-0.5*1.65e-2)'
    preset = false
  []
  [y_bot]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'bottom'
    value = '0'
  []
[]
[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  # [degradation]
  #   type = RationalDegradationFunction
  #   f_name = g
  #   phase_field = d
  #   parameter_names = 'p a2 a3 eta'
  #   parameter_values = '2 1 0 1e-09'
  # []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 0'
  []
  [reg_density]
    type = MaterialConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = SPECTRAL
    decomposition = NONE
    output_properties = 'psie_active psie'
    outputs = exodus
  []
  [strain]
    type = ADComputeSmallStrain
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
  []
  [kumar_material]
    type = NucleationMicroForce
    normalization_constant = c0
    tensile_strength = '${sigma_ts}'
    compressive_strength = '${sigma_cs}'
    delta = '${delta}'
    external_driving_force_name = ce
    output_properties = 'ce'
    outputs = exodus
  []
[]

[Postprocessors]
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'load bottom other' # ? need to define in mesh?
  []
[]

# [Executioner]
#   type = Transient
#   dt = 5e-7
#   # dt = 5e-9
#   end_time = 9e-5
#   solve_type = NEWTON
#   # solve_type = LINEAR
#   petsc_options_iname = '-pc_type'
#   petsc_options_value = 'lu'
#   automatic_scaling = true
#   [TimeIntegrator]
#     # type = CentralDifference
#     # solve_type = lumped
#     # use_constant_mass = true # need to set to be false

#     type = NewmarkBeta
#     gamma = '${fparse 5/6}'
#     beta = '${fparse 4/9}'

#     # type = ExplicitMidpoint
#     # type = ImplicitEular
#   []
#   # [Quadrature]
#   #   order = CONSTANT
#   # []
# []
[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  dt = 5e-7
  # dt = 5e-9
  end_time = 9e-5 # 90 us

    [TimeIntegrator]
    # type = CentralDifference
    # solve_type = lumped
    # use_constant_mass = true # need to set to be false

    type = NewmarkBeta
    gamma = '${fparse 5/6}'
    beta = '${fparse 4/9}'
    []
    
  # fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  fixed_point_max_its = 100
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
[]
[Outputs]
#  file_base = 'exodusfiles/kalthoff/kal_elastic_v200_HHT'
  file_base = './kal_dt5e-7'
  print_linear_residuals = false
  exodus = true
  interval = 1
  # interval = 100
[]
