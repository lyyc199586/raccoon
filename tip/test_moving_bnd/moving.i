[Problem]
  solve = false
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 40
    xmin = 0
    xmax = 100
    ymin = -20
    ymax = 20
  []
  [upper]
    type = ParsedSubdomainMeshGenerator
    input = 'gen'
    block_id = 1
    combinatorial_geometry = 'x < 50 & y > 0'
  []
  [lower]
    type = ParsedSubdomainMeshGenerator
    input = upper
    combinatorial_geometry = 'y < 0'
    block_id = 2
  []
  [split]
    input = lower
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
  []
[]

[UserObjects]
  [moving_circle]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'phi'
    block = 0
    criterion_type = BELOW
    threshold = 0
    subdomain_id = 1
    moving_boundary_name = moving_boundary
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Functions]
  [moving_circle]
    type = ParsedFunction
    expression = 'x-(50+t)'
  []
[]

[AuxVariables]
  [phi]
  []
[]

[AuxKernels]
  [phi]
    type = FunctionAux
    variable = phi
    function = moving_circle
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[Executioner]
  type = Transient
  dt = 1
  num_steps = 10
  start_time = 0
  end_time = 50
[]

[Outputs]
  exodus = true
[]