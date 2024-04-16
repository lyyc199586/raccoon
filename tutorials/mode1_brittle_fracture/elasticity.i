E = 2.1e5
nu = 0.3
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'

Gc = 2.7
l = 0.02

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = fracture.i
    cli_args = 'Gc=${Gc};l=${l}'
    execute_on = 'TIMESTEP_END'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = 'fracture'
    variable = d
    source_variable = d
  []
  [to_psie_active]
    type = MultiAppCopyTransfer
    to_multi_app = 'fracture'
    variable = psie_active
    source_variable = psie_active
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 30
    ny = 15
    ymax = 0.5
  []
  [noncrack]
    type = BoundingBoxNodeSetGenerator
    input = gen
    new_boundary = noncrack
    bottom_left = '0.5 0 0'
    top_right = '1 0 0'
  []
  construct_side_list_from_node_list = true
[]

[Adaptivity]
  marker = marker
  initial_marker = marker
  initial_steps = 2
  stop_time = 0
  max_h_level = 2
  [Markers]
    [marker]
      type = BoxMarker
      bottom_left = '0.4 0 0'
      top_right = '1 0.05 0'
      outside = DO_NOTHING
      inside = REFINE
    []
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [fy]
  []
  [d]
  []
  [d_dist]
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
    save_in = fy
  []
  [inertia_x]
    type = ADInertialForce
    variable = disp_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
  []
[]

[AuxKernels]
  [d_dist]
    type = ParsedAux
    variable = d_dist
    coupled_variables = d
    expression = 'if(d > d_cr, sqrt((x-0.5)^2+y^2), -1)'
    constant_names = d_cr
    constant_expressions = 0.95
    use_xyzt = true
  []
[]

[BCs]
  [ydisp]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = 't'
  []
  [yfix]
    type = DirichletBC
    variable = disp_y
    boundary = noncrack
    value = 0
  []
  [xfix]
    type = DirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
[]

[Materials]
  [bulk]
    type = ADGenericConstantMaterial
    prop_names = 'K G density'
    prop_values = '${K} ${G} 1e-9'
  []
  [degradation]
    type = PowerDegradationFunction
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [strain]
    type = ADComputeSmallStrain
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
[]

[Postprocessors]
  [Fy]
    type = NodalSum
    variable = fy
    boundary = top
    outputs = pp
  []
  # [dist_max_value]
  #   type = NodalExtremeValue
  #   variable = d_dist
  #   outputs = pp
  # []
  # [dist_max_id]
  #   type = NodalMaxValueId
  #   variable = d_dist
  #   outputs = pp
  # []
  # [tip_x]
  #   type = NodalMaxValuePosition
  #   variable = d_dist
  #   coord = x
  #   outputs = tip
  # []
  # [tip_y]
  #   type = NodalMaxValuePosition
  #   variable = d_dist
  #   coord = y
  #   outputs = tip
  # []
  # [tip_z]
  #   type = NodalMaxValuePosition
  #   variable = d_dist
  #   coord = z
  #   outputs = tip
  # []
[]

# [Executioner]
#   type = Transient

#   solve_type = NEWTON
#   petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
#   petsc_options_value = 'lu       superlu_dist                 '
#   automatic_scaling = true

#   nl_rel_tol = 1e-8
#   nl_abs_tol = 1e-10

#   dt = 2e-5
#   end_time = 3.5e-3

#   fixed_point_max_its = 20
#   accept_on_max_fixed_point_iteration = true
#   fixed_point_rel_tol = 1e-8
#   fixed_point_abs_tol = 1e-10
# []

[Executioner]
  type = Transient
  start_time = 0
  end_time = 3.5e-3
  dt = 2e-5

  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'lu'
  [TimeIntegrator]
    type = CentralDifference
  []

  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t<5.8e-5, 1e-7, 0.5e-7)'
  # []
[]

[Outputs]
  exodus = true
  [pp]
    type = CSV
  []
  [tip]
    file_base = crack_tip
    type = CSV
  []
  print_linear_residuals = false
[]
