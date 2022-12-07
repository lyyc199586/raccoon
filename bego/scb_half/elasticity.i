# unit: MPa, mm, s

# BegoStone
# E = 2.735e4
# E = 4.77e3

# E = 6.16e3
# E = 6.417e3 # plane strain
E = 6e3
nu = 0.2
# Gc = 2.188e-2
# Gc = 3.656e-3
Gc = 3.65e-2
# for plane strain G=K^2/E', E'=E/(1-nu^2)
sigma_ts = 10
sigma_cs = 22.27
l = 0.3
delta = 2
# ---------------------------------
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_cs=${sigma_cs};delta=${delta}'
    execute_on = 'TIMESTEP_END'
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
    variable = 'disp_x disp_y psie_active'
    source_variable = 'disp_x disp_y psie_active'
  []
[]

[Problem]
  coord_type = XYZ
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/scb_2d_cw1_half.msh'
  []
  [bot_right]
    type = BoundingBoxNodeSetGenerator
    new_boundary = bot_right
    bottom_left = '16 -0.1 0'
    top_right = '17 0.1 0'
    input = fmg
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
  []
[]

[AuxVariables]
  [d]
  []
  [f_x]
  []
  [f_y]
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
[]

# [Functions]
#   [dts]
#     type = ParsedFunction
#     value = 'if(x<60, 1, 0.1)'
#   []
# []

[Kernels]
  [solid_r]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = f_x
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = f_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[AuxKernels]
  [maxprincipal]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = s1
    scalar_type = MaxPrincipal
    execute_on = timestep_end
  []
  [midprincipal]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = s2
    scalar_type = MidPrincipal
    execute_on = timestep_end
  []
  [minprincipal]
    type = ADRankTwoScalarAux
    rank_two_tensor = 'stress'
    variable = s3
    scalar_type = MinPrincipal
    execute_on = timestep_end
  []
[]

[BCs]
  [center_x]
    type = DirichletBC
    variable = disp_x
    boundary = center
    value = 0
  []
  [bot_right_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bot_right
    # function = '0.12/2/60*t'
    function = 0
  []
  [top_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top
    function = '-0.12/60*t'
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 0'
  []
  # [strain]
  #   type = ADComputeSmallStrain
  #   displacements = 'disp_x disp_y'
  #   output_properties = 'total_strain'
  #   outputs = exodus
  # []
  [strain] # plane stress
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # type = ADComputeSmallStrain
    output_properties = 'total_strain'
    outputs = exodus
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
  # [crack_geometric]
  #   type = CrackGeometricFunction
  #   f_name = alpha
  #   function = 'd'
  #   phase_field = d
  # []
  # [kumar_material]
  #   type = NucleationMicroForce
  #   normalization_constant = c0
  #   tensile_strength = '${sigma_ts}'
  #   compressive_strength = '${sigma_cs}'
  #   delta = '${delta}'
  #   external_driving_force_name = ce
  #   output_properties = 'ce'
  #   outputs = exodus
  # []
[]

[Postprocessors]
  # [Jint]
  #   type = PhaseFieldJIntegral
  #   J_direction = '1 0 0'
  #   strain_energy_density = psie
  #   displacements = 'disp_x disp_y'
  #   boundary = 'left top right bottom'
  # []
  # [Jint_over_Gc]
  #   type = ParsedPostprocessor
  #   function = 'Jint/${Gc}'
  #   pp_names = 'Jint'
  #   use_t = false
  # []
  [top_react]
    type = NodalSum
    variable = f_y
    boundary = top
  []
  [top_disp]
    type = NodalVariableValue
    variable = disp_y
    # nodeid = 26856 # for scb_2d.msh
    # nodeid = 24156 # for scb_2d_cw0.4.msh
    nodeid = 11210 # for scb_half_cw1
  []
  [bot_react]
    type = NodalSum
    variable = f_y
    boundary = bot_right
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [w_ext_top]
    type = ExternalWork
    displacements = 'disp_y'
    forces = f_y
    boundary = top
  []
  [w_ext_bottom]
    type = ExternalWork
    displacements = 'disp_y'
    forces = f_y
    boundary = bot_right
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  end_time = 50
  dt = 0.2
  # [TimeStepper]
  #   type = FunctionDT 
  #   function = 'if(t<60, 1, 0.01)'
  # []

  # fast
  # fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  # fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8
  # fixed_point_rel_tol = 1e-5
  # fixed_point_abs_tol = 1e-6
[]

[Outputs]
  # [exodus1]
  #   type = Exodus
  #   interval = 10
  #   end_time = 60
  # []
  [exodus]
    type = Exodus
    interval = 1
    start_time = 0
  []
  # file_base = './scb_cw1_E${E}_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  file_base = './scb_cw1_E${E}_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  # file_base = './scb_${E}_ts${sigma_ts}_cs${sigma_cs}'
  print_linear_residuals = false
  [csv]
    type = CSV
    # file_base = 'scb'
  []
[]
