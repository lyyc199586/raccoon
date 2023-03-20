# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2.54e-9 # Mg/mm^3
Gc = 3e-3 # N/mm -> 3 J/m^2
sigma_ts = 3.08 # MPa, sts and scs from guessing
sigma_cs = 9.24

l = 2
delta = 4 # haven't tested

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};delta=${delta};'
               'sigma_cs=${sigma_cs};sigma_ts=${sigma_ts}'
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
    variable = 'disp_x disp_y strain_zz psie_active'
    source_variable = 'disp_x disp_y strain_zz psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  # [gen]
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = 400
  #   ny = 160
  #   # nx = 800
  #   # ny = 320
  #   xmin = 0
  #   xmax = 100
  #   ymin = -20
  #   ymax = 20
  # []
  [gen1]
    use_for_exodus_restart = true
    type = FileMeshGenerator
    file = './outputs/elasticity_ce2021_ts3.08_cs9.24_l2_delta4_dt5e-7.e'
  []
[]

[Variables]
  [disp_x]
    initial_from_file_var = 'disp_x' 
    initial_from_file_timestep = LATEST
  []
  [disp_y]
    initial_from_file_var = 'disp_y' 
    initial_from_file_timestep = LATEST
  []
  [strain_zz]
    initial_from_file_var = 'strain_zz' 
    initial_from_file_timestep = LATEST
  []
[]

[AuxVariables]
  [fy]
  []
  [d]
    [InitialCondition]
      type = FunctionIC
      function = 'if(y=0&x>=0&x<=50,1,0)'
    []
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
  [inertia_x]
    type = InertialForce
    variable = disp_x
    density = reg_density
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    density = reg_density
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    component = 1
    boundary = top
    constant = -1
  []
  [ybottom]
    type = ADPressure
    variable = disp_y
    component = 1
    boundary = bottom
    constant = -1
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-5'
  []
  [reg_density]
    type = MaterialADConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
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
  [Fy]
    type = NodalSum
    variable = fy
    boundary = top
  []
  [disp_y]
    type = PointValue
    point = '0 20 0'
    variable = disp_y
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top' # ? need to define in mesh?
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'asm'
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = 5e-7
  # end_time = 80e-6

  # restart
  start_time = 80e-6
  end_time = 120e-6

  fixed_point_max_its = 50
  accept_on_max_fixed_point_iteration = true
  # fixed_point_rel_tol = 1e-8
  # fixed_point_abs_tol = 1e-10
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  [TimeIntegrator]
    type = NewmarkBeta
    gamma = '${fparse 5/6}'
    beta = '${fparse 4/9}'
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
  []
  print_linear_residuals = false
  file_base = './outputs/elasticity_ce2021_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}_dt5e-7_ctd'
  interval = 1
  [./csv]
    type = CSV 
  [../]
[]