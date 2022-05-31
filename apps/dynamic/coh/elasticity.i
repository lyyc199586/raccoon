E = 3.09e3 # 32 GPa
nu = 0.35
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
psic = '${fparse sigma_ts^2/2/E}'

rho = 1.18e-9 # Mg/mm^3
## case a

case = a
# Gc = 0.8 # case as
Gc = 1.25
# Gc = 1.588
sigma_ts = 50 # MPa
# l = '${fparse 27/256*E*Gc/sigma_ts^2}'
l = 0.163
du = 0.06
file = '../qs/el/at1_qs_a_l0.2.e'

## case b

# case = b
# Gc = 5.063 # case b
# l = 0.4
# du = 0.1

## case c

# case = c
# Gc = 9.420 # case c
# l = 0.6
# du = 0.14



[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l};psic=${psic};file=${file}'
    execute_on = 'TIMESTEP_END'
    clone_master_mesh = true
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    variable = 'd'
    source_variable = 'd'
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    variable = 'psie_active'
    source_variable = 'psie_active'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  out_of_plane_strain = strain_zz
[]

[Mesh]
  # [gen]
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = 100
  #   ny = 50
  #   xmin = 0
  #   xmax = 32
  #   ymin = -8
  #   ymax = 8
  # []
  [fmg]
    type = FileMeshGenerator
    use_for_exodus_restart = true
    file = '${file}'
  []
[]

# [Adaptivity]
#   marker = marker
#   initial_marker = marker
#   initial_steps = 2
#   stop_time = 0
#   max_h_level = 2
#   [Markers]
#     [marker]
#       type = BoxMarker
#       bottom_left = '0 -2 0'
#       top_right = '32 2 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#   []
# []

[UserObjects]
  [sol]
    type = SolutionUserObject
    mesh = '${file}'
    system_variables = 'disp_x disp_y d fx fy'
    timestep = LATEST
  []
[]

[Functions]
  [d_ic]
    type = SolutionFunction
    solution = sol
    from_variable = d
  []
  [disp_x_ic]
    type = SolutionFunction
    solution = sol
    from_variable = disp_x
  []
  [disp_y_ic]
    type = SolutionFunction
    solution = sol
    from_variable = disp_y
  []
  # [fy_ic]
  #   type = SolutionFunction
  #   solution = sol
  #   from_variable = fy
  # []
  # [fx_ic]
  #   type = SolutionFunction
  #   solution = sol
  #   from_variable = fx
  # []
[]

[Variables]
  [disp_x]
    [InitialCondition]
      type = FunctionIC
      function = disp_x_ic
    []
  []
  [disp_y]
    [InitialCondition]
      type = FunctionIC
      function = disp_y_ic
    []
  []
  [strain_zz]
  []
[]

[AuxVariables]
  [fy]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = fy_ic
    # []
  []
  [fx]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = fx_ic
    # []
  []
  [d]
    [InitialCondition]
      type = FunctionIC
      function = d_ic
    []
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
  [plane_stress]
     type = ADWeakPlaneStress
     variable = strain_zz
  []
  [inertia_x]
    type = InertialForce
    variable = disp_x
    density = reg_density
    use_displaced_mesh = false
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    density = reg_density
    use_displaced_mesh = false
  []
[]

[BCs]
  [y_top]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = bc_top
  []
  # [y_bottom]
  #   type = FunctionDirichletBC
  #   variable = disp_y
  #   boundary = bottom
  #   function = bc_bottom
  # []
  [y_center]
    type = DirichletBC
    variable = disp_y
    boundary = noncrack
    value = 0
  []
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = fix_point
    value = 0
  []
[]

[Functions]
  [bc_top]
    type = ParsedFunction
    value = 'du'
    vars = 'du'
    vals = ${du}
  []
  [bc_bottom]
    type = ParsedFunction
    value = '-du'
    vars = 'du'
    vals = ${du}
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    function = (1-d)^p/((1-d)^p+(Gc/psic*xi/c0/l)*d*(1+a2*d+a2*a3*d^2))*(1-eta)+eta
    phase_field = d
    material_property_names = 'Gc psic xi c0 l '
    parameter_names = 'p a2 a3 eta '
    parameter_values = '2 -0.5 0 1e-6'
  []
  [reg_density]
    type = MaterialConverter
    ad_props_in = 'density'
    reg_props_out = 'reg_density'
  []
  [strain]
    # type = ADComputeSmallStrain
    type = ADComputePlaneSmallStrain
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'elastic_strain psie_active'
    outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    outputs = exodus
  []
  [fracture_energy_density]
    type = ADParsedMaterial
    f_name = psif
    function = 'Gc * gamma'
    material_property_names = 'Gc gamma'
  []
  [total_energy_density]
    type = ADParsedMaterial
    f_name = psie_psif
    function = 'psie + psif'
    material_property_names = 'psie psif'
 [] 
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = top
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = top
  []
  [out_disp_y]
    type = PointValue
    point = '0 8 0'
    variable = disp_y
  []
  [d_tip]
    type = PointValue
    point = '4 0 0'
    variable = d
  []
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left right top' # ? need to define in mesh?
  []
  [external_work]
    type = ExternalWork
    boundary = 'top'
    forces = 'fy'
    displacements = 'disp_y'
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [kinetic_energy]
    type = KineticEnergy 
    displacements = 'disp_x disp_y'
    density = density
  []
  [fracture_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psif
  []
  [total_energy] # strain energy + fracture energy
    type = ADElementIntegralMaterialProperty
    mat_prop = psie_psif
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true

  # nl_rel_tol = 1e-8
  # nl_abs_tol = 1e-10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  dt = 1e-7 # 1 us
  start_time = 0
  end_time = 100e-6 # 50 us

  fixed_point_max_its = 100
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

  [TimeIntegrator]
    type = NewmarkBeta
    gamma = '${fparse 1/2}'
    beta = '${fparse 1/4}'
  []
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  file_base = './coh_case_${case}_l${l}'
  interval = 10
  [./csv]
    type = CSV 
    interval = 1
  [../]
[]
