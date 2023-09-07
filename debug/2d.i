[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 5
    xmax = 2
    ymax = 0.5
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    component = 0
    variable = disp_x
  []
  [solid_y]
    type = ADStressDivergenceTensors
    component = 1
    variable = disp_y
  []
[]

[BCs]
  [left]
    type = ADDirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [right]
    type = ADFunctionDirichletBC
    variable = disp_x
    boundary = right
    function = '0.1*t'
  []
[]

[Materials]
  [elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 0.02735 # MPa
    poissons_ratio = 0.1
  []
  [stress]
    type = ADComputeLinearElasticStress
  []
  [strain]
    type = ADComputeSmallStrain
  []
[]

[Postprocessors]
  [dt]
    type = TimestepSize
    outputs = 'csv'
  []
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
  end_time = 1
  dt = 0.1
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 1
    minimum_time_interval = 0.2
  []
  [csv]
    type = CSV
    interval = 1
    minimum_time_interval = 0.2
  []
[]