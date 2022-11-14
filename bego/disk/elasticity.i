# BegoStone
# E = 2.735e4
E = 4.77e3
nu = 0.2
# Gc = 2.188e-2
# Gc = 3.656e-3
Gc = 3.656e-2
sigma_ts = 10
sigma_cs = 22.27
# sigma_cs = 100
l = 0.3
delta = 1
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
    file = '../mesh/disk_2d.msh'
  []
  [top_p]
    type = ExtraNodesetGenerator
    input = fmg
    new_boundary = top_point
    coord = '0 2.9 0'
  []
  [bot_p]
    type = ExtraNodesetGenerator
    input = top_p
    new_boundary = bot_point
    coord = '0 -2.9 0'
  []
  # [top_arc]
  #   type = ParsedGenerateSideset
  #   combinatorial_geometry = 'x*x+y*y>2.895^2 & y>2.8'
  #   new_sideset_name = 'top_arc'
  #   input = fmg
  # []
  # [bot_arc]
  #   type = ParsedGenerateSideset
  #   combinatorial_geometry = 'x*x+y*y>2.895^2 & y<-2.8'
  #   new_sideset_name = 'bot_arc'
  #   input = top_arc
  # []
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
  [bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = bot_point
    value = 0
  []
  [top_x]
    type = DirichletBC
    variable = disp_x
    boundary = top_point
    value = 0
  []
  [bottom_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bot_point
    function = '0.5/60/2*t'
  []
  [top_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top_point
    function = '-0.5/60/2*t'
  []
  # [bottom_y]
  #   type = ADFunctionDirichletBC
  #   variable = disp_y
  #   boundary = bot_arc
  #   function = '0.12/60/2*t*(sqrt(2.9^2-x^2)-2.8)/0.1'
  # []
  # [top_y]
  #   type = ADFunctionDirichletBC
  #   variable = disp_y
  #   boundary = top_arc
  #   function = '-0.12/60/2*t*(sqrt(2.9^2-x^2)-2.8)/0.1'
  # []
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
    parameter_values = '2 0.5'
  []
  [strain]
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
    boundary = top_point
  []
  [bot_react]
    type = NodalSum
    variable = f_y
    boundary = bot_point
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [w_ext_top]
    type = ExternalWork
    displacements = 'disp_y'
    forces = f_y
    boundary = top_point
  []
  [w_ext_bottom]
    type = ExternalWork
    displacements = 'disp_y'
    forces = f_y
    boundary = bot_point
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

  end_time = 100
  dt = 0.1
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
  fixed_point_rel_tol = 1e-8
  fixed_point_abs_tol = 1e-10
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
    interval = 10
    start_time = 0
  []
  # file_base = './disk_vd_E${E}_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  file_base = './disk_k0.5'
  print_linear_residuals = false
  [csv]
    type = CSV
    # file_base = 'disk'
  []
[]
