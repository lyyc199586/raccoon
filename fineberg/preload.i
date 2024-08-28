# MPa, mm, us
G = 31.44e-3
K = '${fparse 10*G}'

u0 = 4.5
# u0 = 1
# u0 = 9
# u0 = 27
t0 = 0.01
h = 0.125
refine = 2
cw = 2 # crack region width
# l = 1

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/fineberg_cw${cw}_h${h}.msh'
  []
  [initial_refine_block]
    type = RefineSidesetGenerator
    boundaries = 'pre_crack_upper pre_crack_lower'
    input = fmg
    refinement = '${refine} ${refine}'
    boundary_side = 'both both'
  []
  # [gen] # h = 0.25
  #   type = GeneratedMeshGenerator
  #   dim = 2
  #   nx = ${fparse 60/h}
  #   ny = ${fparse 90/h}
  #   xmin = 0
  #   xmax = 60
  #   ymin = -45
  #   ymax = 45
  # []
  # [crack_region]
  #   type = ParsedSubdomainMeshGenerator
  #   input = gen
  #   combinatorial_geometry = 'abs(y) <= 4'
  #   block_id = 1
  # []
  # [refine]
  #   type = RefineBlockGenerator
  #   block = 1
  #   input = crack_region
  #   refinement = ${refine}
  # []
  # [merge_refine_block]
  #   type = RenameBlockGenerator
  #   input = refine
  #   old_block = '1'
  #   new_block = '0'
  # []
  # [upper]
  #   type = ParsedSubdomainMeshGenerator
  #   # input = merge_refine_block
  #   input = gen
  #   combinatorial_geometry = 'x < 2 & y > 0'
  #   block_id = 1
  # []
  # [lower]
  #   type = ParsedSubdomainMeshGenerator
  #   input = upper
  #   combinatorial_geometry = 'x < 2 & y < 0'
  #   block_id = 2
  # []
  # [split]
  #   input = lower
  #   type = BreakMeshByBlockGenerator
  #   block_pairs = '1 2'
  #   split_interface = true
  #   add_interface_on_two_sides = true
  # []
  # [merge_split_block]
  #   type = RenameBlockGenerator
  #   input = split
  #   old_block = '1 2'
  #   new_block = '0 0'
  # []
  construct_node_list_from_side_list = true
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
  [F]
    order = CONSTANT
    family = MONOMIAL
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
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = strain_zz
    use_displaced_mesh = true
  []
[]

[AuxKernels]
  [F]
    type = ADRankTwoAux
    variable = F
    rank_two_tensor = deformation_gradient
    index_i = 1
    index_j = 1
  []
[]

[Functions]
  [top_func]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 ${u0}'
  []
  [bottom_func]
    type = PiecewiseLinear
    x = '0 ${t0}'
    y = '0 -${u0}'
  []
[]

[BCs]
  [ytop]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = top
    function = top_func
  []
  [ybottom]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = bottom_func
  []
  [xtop]
    type = ADDirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
  [xbottom]
    type = ADDirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
  # [yupper]
  #   type = ADDirichletBC
  #   variable = disp_y
  #   boundary = 'Block1_Block2'
  #   value = 0
  # []
  # [ylower]
  #   type = ADDirichletBC
  #   variable = disp_y
  #   boundary = 'Block2_Block1'
  #   value = 0
  # []
  [crack_upper]
    type = ADDirichletBC
    variable = disp_y
    boundary = pre_crack_upper
    value = 0
  []
  [crack_lower]
    type = ADDirichletBC
    variable = disp_y
    boundary = pre_crack_lower
    value = 0
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'K G'
    prop_values = '${K} ${G}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [nodeg]
    type = NoDegradation
    property_name = g
    phase_field = d
  []
  [cnh]
    type = CNHIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
  []
  [stress]
    type = ComputeLargeDeformationStress
    elasticity_model = cnh
    output_properties = 'stress'
    outputs = 'exodus'
  []
  [defgrad]
    type = ComputePlaneDeformationGradient
    out_of_plane_strain = strain_zz
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist     '
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true

  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  nl_max_its = 100

  # dt = ${fparse t0*0.1}
  dt = ${fparse t0*0.025}
  # dt = ${fparse t0*0.005}
  # dt = ${t0}
  end_time = ${t0}

  # [TimeIntegrator]
  #   type = NewmarkBeta
  # []
[]

[Outputs]
  [exodus]
    # time_step_interval = ${fparse t0*0.1}
    min_simulation_time_interval = ${fparse t0*0.05}
    type = Exodus
  []
  print_linear_residuals = false
  # file_base = './pre_y_free_u${u0}_h${h}'
  # file_base = './pre_free_u${u0}_h${h}_rf${refine}'
  file_base = './pre_free_cw${cw}_u${u0}_h${h}_rf${refine}'
  time_step_interval = 1
[]
