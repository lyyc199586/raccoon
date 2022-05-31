E = 3.09e3 # 32 GPa
nu = 0.35
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
# psic = '${fparse sigma_ts^2/2/E}'

rho = 1.18e-9 # Mg/mm^3

## case a

case = a
# Gc = 1.549 # case a
Gc = 1.2
l = 0.2
du = 0.06

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
    cli_args = 'E=${E};K=${K};G=${G};Lambda=${Lambda};Gc=${Gc};l=${l}'
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
  #   nx = 200
  #   ny = 50
  #   xmin = 0
  #   xmax = 32
  #   ymin = 0
  #   ymax = 8
  # []
  [gen2]
    type = ExtraNodesetGenerator
    input = fmg
    new_boundary = fix_point
    coord = '0 8'
  []
  [noncrack]
    type = BoundingBoxNodeSetGenerator
    input = gen2
    new_boundary = noncrack
    bottom_left = '4 0 0'
    top_right = '32 0 0'
  []
  construct_side_list_from_node_list = true
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/half.msh'
  []
[]

# [Adaptivity]
#   marker = marker1
#   initial_marker = marker1
#   initial_steps = 2
#   stop_time = 0
#   max_h_level = 3
#   [Markers]
#     [marker1]
#       type = BoxMarker
#       bottom_left = '0 0 0'
#       top_right = '32 1 0'
#       outside = DO_NOTHING
#       inside = REFINE
#     []
#   []
# []

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
  []
[]

[AuxVariables]
  [fx]
  []
  [fy]
  []
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(y=0&x>=0&x<=4,1,0)'
    # []
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
[]

[BCs]
  [y_top]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = bc_top
  []
  # [x_top]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = top
  #   value = 0
  # []
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
    value = 'if(t<1, du*t, du)'
    vars = 'du'
    vals = ${du}
  []
  [bc_bottom]
    type = ParsedFunction
    value = 'if(t<1, -du*t, -du)'
    vars = 'du'
    vals = ${du}
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
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
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
    output_properties = 'elastic_strain psie_active psie'
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
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right' # ? need to define in mesh?
  []
  [external_work]
    type = ExternalWork
    boundary = 'top'
    forces = 'fy'
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [kinetic_energy]
    type = KineticEnergy 
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

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8

  dt = 0.1
  end_time = 1

  fixed_point_max_its = 100
  accept_on_max_fixed_point_iteration = false
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-8

[]

[Outputs]
  exodus = true
  # checkpoint = true
  print_linear_residuals = false
  file_base = './el/at1_qs_${case}_l${l}'
  interval = 1
  [./csv]
    type = CSV 
  [../]
[]
