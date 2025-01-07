# l = 0.2e-6
Gc = 10
Tmax = 80e6

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/cubes.msh'
  []
  [break]
    type = BreakMeshByBlockGenerator
    input = fmg
    split_interface = true
    block_pairs = '8 9'
  []
[]

[Physics]

  [SolidMechanics]

    [CohesiveZone]
      [czm_interface]
        boundary = 'Lower_Upper'
        strain = FINITE
        generate_output = 'normal_traction tangent_traction normal_jump tangent_jump'
      []
    []
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  use_displaced_mesh = false
  # large_kinematics = true
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoAux
      rank_two_tensor = stress
      index_i = 0
      index_j = 0
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoAux
      rank_two_tensor = stress
      index_i = 1
      index_j = 1
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ADRankTwoAux
      rank_two_tensor = stress
      index_i = 2
      index_j = 2
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [fx]
  []
  [fy]
  []
  [fz]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    displacements = 'disp_x disp_y disp_z'
    component = 0
    save_in = fx
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    displacements = 'disp_x disp_y disp_z'
    component = 1
    save_in = fy
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_z
    displacements = 'disp_x disp_y disp_z'
    component = 2
    save_in = fz
  []
[]

[Functions]
  [load_func]
    type = PiecewiseLinear
    x = '0 100'
    y = '0 2e-7'
  []
[]

[BCs]
  [zbottom]
    type = ADDirichletBC
    variable = disp_z
    boundary = 'Bottom'
    value = 0
  []
  [ztop]
    type = ADFunctionDirichletBC
    boundary = 'Top'
    variable = disp_z
    function = load_func
  []
  [fix_x]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = 'Bottom'
  []
  [fix_y]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = 'Bottom'
  []
[]

[Materials]
  [pzt]
    type = ADComputeElasticityTensor
    C_ijkl = '1.39e11 7.78e10 7.43e10 1.39e11 7.43e10 1.15e11 2.56e10 2.56e10 3.06e10'
    fill_method = SYMMETRIC9
  []
  [czm]
    type = BiLinearMixedModeTraction
    boundary = 'Lower_Upper'
    GII_c = ${Gc}
    GI_c = ${Gc}
    eta = 2
    normal_strength = ${Tmax}
    penalty_stiffness = 1e15
    shear_strength = ${Tmax}
  []
  # [czm]
  #   type = PureElasticTractionSeparation
  #   boundary = 'Lower_Upper'
  #   normal_stiffness =
  #   tangent_stiffness =
  # []
  [stress]
    type = ADComputeLinearElasticStress
    output_properties = 'stress'
    # outputs = 'exodus'
  []
  [strain]
    type = ADComputeSmallStrain
  []
[]

[Postprocessors]
  [Fz]
    type = NodalSum
    variable = fz
    boundary = 'Top'
  []
  [max_disp_z]
    type = NodalExtremeValue
    variable = disp_z
    value_type = max
  []
  [max_normal_traction]
    type = ElementExtremeValue
    variable = normal_traction
    value_type = max
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0
  end_time = 100
  dt = 1
  dtmin = 1e-8
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu       superlu_dist                 '
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  line_search = None
[]

[Outputs]
  [exodus]
    type = Exodus
    simulation_time_interval = 1
    time_step_interval = 1
  []
  print_linear_residuals = false
  file_base = './out/elastic_czm'
  checkpoint = true
[]