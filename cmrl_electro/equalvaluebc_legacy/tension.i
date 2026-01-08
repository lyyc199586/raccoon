p = 1e12

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/cube.msh'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[Kernels]
  [solid_x]
    type = TotalLagrangianStressDivergence
    variable = disp_x
    displacements = 'disp_x disp_y disp_z'
    component = 0
  []
  [solid_y]
    type = TotalLagrangianStressDivergence
    variable = disp_y
    displacements = 'disp_x disp_y disp_z'
    component = 1
  []
  [solid_z]
    type = TotalLagrangianStressDivergence
    variable = disp_z
    displacements = 'disp_x disp_y disp_z'
    component = 2
  []
[]

[Functions]
  [load_func]
    type = PiecewiseLinear
    x = '0.0 50e-7'
    y = '0.0 5e-3'
  []
[]

[BCs]
  [fix_bottom_z]
    type = ADDirichletBC
    boundary = bottom
    value = 0
    variable = disp_z
  []
  [fix_bottom_x]
    type = ADDirichletBC
    boundary = bottom
    value = 0
    variable = disp_x
  []
  [fix_bottom_y]
    type = ADDirichletBC
    boundary = bottom
    value = 0
    variable = disp_y
  []
  [fix_left]
    type = ADDirichletBC
    boundary = left
    value = 0
    variable = disp_x
  []
  [fix_back]
    type = ADDirichletBC
    boundary = back
    value = 0
    variable = disp_y
  []
  [load_top]
    type = ADFunctionDirichletBC
    boundary = top
    function = load_func
    variable = disp_z
  []
  [fix_top_x]
    type = ADDirichletBC
    boundary = top
    value = 0
    variable = disp_x
  []
  [fix_top_y]
    type = ADDirichletBC
    boundary = top
    value = 0
    variable = disp_y
  []
[]

[Constraints]
  [ev_x]
    type = EqualValueBoundaryConstraint
    variable = disp_x
    secondary = right
    penalty = ${p}
  []
  [ev_y]
    type = EqualValueBoundaryConstraint
    variable = disp_y
    secondary = front
    penalty = ${p}
  []
[]

[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    shear_modulus = 70e9
    poissons_ratio = 0.35
  []
  [stress]
    type = ComputeLagrangianLinearElasticStress
    outputs = 'exodus'
    output_properties = 'cauchy_stress'
  []
  [strain]
    type = ComputeLagrangianStrain 
    displacements = 'disp_x disp_y disp_z'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0
  end_time = 50e-7
  dt = 5e-7
  dtmin = 1e-8
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  line_search = None
[]

[Outputs]
  print_linear_residuals = false
  file_base = './out/tension_p${p}'
  # file_base = './out/tension_wo_ev'
  checkpoint = false
  # exodus = true
  [exodus]
    type = Exodus
  []
[]