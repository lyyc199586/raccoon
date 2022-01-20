[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 3
  ny = 3
[]

[Problem]
  coord_type = RZ
[]

[GlobalParams]
  displacements = 'disp_r disp_z'
[]

[Variables]
  # scale with one over Young's modulus
  [./disp_r]
    scaling = 1e-10
  [../]
  [./disp_z]
    scaling = 1e-10
  [../]
[]

[AuxVariables]
  [./stress_rr]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./stress_rr]
    type = ADStressDivergenceRZTensors
    component = 0
    variable = disp_r
  [../]
  [./stress_zz]
    type = ADStressDivergenceRZTensors
    component = 1
    variable = disp_z
  [../]
[]

[AuxKernels]
  [./stress_rr]
    type = ADRankTwoAux
    variable = 'stress_rr'
    rank_two_tensor = 'stress'
    index_i = 0
    index_j = 0
  [../]
  [./stress_zz]
    type = ADRankTwoAux
    variable = 'stress_zz'
    rank_two_tensor = 'stress'
    index_i = 1
    index_j = 1
  [../]
[]

[BCs]
  [./bottom]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0
  [../]
  [./axial]
    type = DirichletBC
    variable = disp_r
    boundary = left
    value = 0
  [../]
  [./rdisp]
    type = DirichletBC
    variable = disp_r
    boundary = right
    value = 0.1
  [../]
[]

[Materials]
  [./elasticity]
    type = ADComputeIsotropicElasticityTensor
    poissons_ratio = 0.3
    youngs_modulus = 1e10
  [../]
  [./strain]
    type = ADComputeAxisymmetricRZSmallStrain
  [../]
  [./stress]
    type = ADComputeLinearElasticStress
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.05
  solve_type = 'NEWTON'

  petsc_options_iname = -pc_hypre_type
  petsc_options_value = boomeramg

  dtmin = 0.05
  num_steps = 1
[]

[Outputs]
  exodus = true
[]