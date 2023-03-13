# BegoStone
E = 6.16e3
nu = 0.2
Gc = 3.656e-2
sigma_ts = 10
sigma_cs = 80
l = 0.1
delta = 6
# a = 10
# ---------------------------------
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};sigma_ts=${sigma_ts};sigma_cs=${sigma_cs};delta=${delta}'
    execute_on = 'TIMESTEP_END' #a=${a};
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
    type = MultiAppCopyTransfer # MultiAppGeneralFieldShapeEvaluationTransfer #
    to_multi_app = fracture
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  coord_type = XYZ
  [fmg]
    type = FileMeshGenerator
    # file = 'disk_2d_h0.01_us.msh'
    file = 'Brazilian2.msh'
    ### for recover
    # use_for_exodus_restart = true
    # file = './solid_a10_ts10_cs80_l0.1_delta8.e'
  []
  [top_arc]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-2.9^2)<1e-4 & y>2.9*sin(80/180*3.1415926)'
    new_sideset_name = 'top_arc'
    input = fmg
  []
  [bot_arc]
    type = ParsedGenerateSideset
    # combinatorial_geometry = 'x*x+y*y>2.895^2 & y<-2.9*cos(${a}/180*3.1415926)'
    combinatorial_geometry = 'abs(x*x+y*y-2.9^2)<1e-4 & y<-2.9*sin(80/180*3.1415926)'
    new_sideset_name = 'bot_arc'
    input = top_arc
  []
  [fix_point]
    type = BoundingBoxNodeSetGenerator
    input = bot_arc
    new_boundary = fix_point
    bottom_left = '-1e-4 2.8999 0'
    top_right = '1e-4 2.9001 0'
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
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(x=0&x>=-0.5&x<=0.5,1,0)'
    # []
  []
[]

[Kernels]
  [solid_r]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[BCs]
  [top_x]
    type = ADDirichletBC
    variable = disp_x
    boundary = fix_point
    value = 0
  []
  [bottom_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bot_arc
    function = '0.05*t'
  []
  [top_y]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top_arc
    function = '-0.05*t'
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
    function = (1-d)^p+eta #(1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # type = ADComputeSmallStrain
    output_properties = 'total_strain'
    # outputs = exodus
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # decomposition = VOLDEV
    output_properties = 'psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
[]

# [Dampers]
#   [disp_damp]
#     type = ElementJacobianDamper
#     max_increment = 0.1
#     displacements = 'disp_x disp_y'
#   []
# []

[Postprocessors]
  # [top_react]
  #   type = NodalSum
  #   variable = f_y
  #   # boundary = top_point
  #   boundary = top_arc
  # []
  # [bot_react]
  #   type = NodalSum
  #   variable = f_y
  #   # boundary = bot_point
  #   boundary = bot_arc
  # []
  # [strain_energy]
  #   type = ADElementIntegralMaterialProperty
  #   mat_prop = psie
  # []
  # [w_ext_top]
  #   type = ExternalWork
  #   displacements = 'disp_y'
  #   forces = f_y
  #   # boundary = top_point
  #   boundary = top_arc
  # []
  # [w_ext_bottom]
  #   type = ExternalWork
  #   displacements = 'disp_y'
  #   forces = f_y
  #   # boundary = bot_point
  #   boundary = bot_arc
  # []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true
  # off_diagonals_in_auto_scaling = true
  line_search = bt
  # compute_scaling_once = False

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10

  #### for pressure bc
  # end_time = 200
  # dt = 1

  ### for disp bc
  end_time = 1
  # dt = 2e-3

  ### restart
  # start_time = 7
  # end_time = 8
  # dt = 0.1

  [TimeStepper]
    type = FunctionDT
    function = 'if(t<0.35, 0.05, 2e-3)' #0.25
  []

  # fast
  # fixed_point_max_its = 20
  # accept_on_max_fixed_point_iteration = false
  # fixed_point_rel_tol = 1e-3
  # fixed_point_abs_tol = 1e-5

  fixed_point_max_its = 100
  accept_on_max_fixed_point_iteration = true
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
    # interval = 1
    # start_time = 0
  []
  file_base = ela_strainzz_2021correct_kumarmesh_eta1e-5_tol68maxitr100accept_BCfix
  # file_base = './disk_vd_E${E}_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
  # file_base = './disk_a${a}_l${l}_delta${delta}_d_center'
  # file_base = './output/solid_a${a}_ts${sigma_ts}_cs${sigma_cs}_l${l}_us_delta${delta}'
  print_linear_residuals = false
  [csv]
    type = CSV
    # file_base = 'disk'
  []
[]
