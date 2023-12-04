
[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    # nx = 200
    # ny = 50
    nx = 400
    ny = 50
    xmin = 0
    xmax = 2
    ymin = 0
    ymax = 0.5
  []
[]

[Variables]
  [p]
  []
[]

[AuxVariables]
  [accel_x_in]
  []
[]

[Kernels]
  [intertia_p]
    type = InertialForce
    variable = p
  []
  [diff_p]
    type = ADCoefMatDiffusion
    variable = 'p'
    prop_names = 'Diff' # diffusivity
  []
[]

[Functions]
  [p_func]
    type = ADParsedFunction
    # expression = 'if(t<0.25*T, 0.25*amp*(1 - cos(2*pi*t/(0.25*T))), 0)'
    expression = 'if(t<0.25*T, 0.5*amp*sin(pi*t/(0.25*T)), 0)'
    symbol_names = 'amp T'
    symbol_values = '2.2e-5 1'
  []
[]

[BCs]
  [left_in]
    type = ADFunctionDirichletBC
    boundary = left
    variable = p
    function = p_func
  []
  # [right_back]
  #   type = CoupledVarNeumannBC
  #   boundary = right
  #   variable = p
  #   v = accel_x_in
  # []
[]

[Materials]
  [density] # this is actually the coef = 1/rho/cf^2
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 444.44
  []
  [water_density] # rho
    type = GenericConstantMaterial
    prop_names = water_density
    prop_values = 1000
  []
  [water_wavespeed] # cf
    type = ADGenericConstantMaterial
    prop_names = water_wavespeed
    prop_values = 1.5
  []
  [diff] # this is actually the coef = 1/rho
    type = ADGenericConstantMaterial
    prop_names = 'Diff'
    prop_values = '1000'
  []
[]

# [VectorPostprocessors]
#   [f]
#     type = LineValueSampler
#     variable = 'p'
#     start_point = '0 0 0'
#     end_point = '2 0 0'
#     num_points = 200
#     sort_by = x
#     outputs = vpp
#   []
# []

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  end_time = 2.2
  dt = 0.5e-3
  # dt = 0.25e-3
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
  [exodus]
    type = Exodus
    interval = 50
    file_base = './out/fluid_h0.005'
  []
  # [vpp]
  #   type = CSV
  #   interval = 50
  #   file_base = './out/vpp/line'
  # []
[]