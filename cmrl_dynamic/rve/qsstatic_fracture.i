# material params,
# rho_epoxy = 1.3e3
# rho_pzt = 2.6e3
K_epoxy = 2.17e6
G_epoxy = 1e6
K_pzt = 115e6
G_pzt = 4.5e6
l = 0.022
Gc = 0.1

# hht params
# hht_alpha = -0.0
# beta = '${fparse (1-hht_alpha)^2/4}'
# gamma = '${fparse 1/2-hht_alpha}'

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './mesh/compositeRVE.msh'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  # alpha = ${hht_alpha}
  # beta = ${beta}
  # gamma = ${gamma}
  # large_kinematics = true
  use_displaced_mesh = false
  # use_displaced_mesh = true
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [d]
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
  [bounds_dummy]
  []
[]

[Kernels]
  [solid_x]
    type = ADStressDivergenceTensors
    variable = disp_x
    displacements = 'disp_x disp_y disp_z'
    component = 0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = disp_y
    displacements = 'disp_x disp_y disp_z'
    component = 1
  []
  [solid_z]
    type = ADStressDivergenceTensors
    variable = disp_z
    displacements = 'disp_x disp_y disp_z'
    component = 2
  []
  [pff_diff]
    type = ADPFFDiffusion
    variable = d
  []
  [pff_source]
    type = ADPFFSource
    variable = d
    free_energy = psi
  []
[]

[Bounds]
  [irreversibility]
    type = VariableOldValueBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = lower
  []
  [upper]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
  []
[]

[Functions]
  # [load_func]
  #   type = PiecewiseLinear
  #   x = '0.00 1.00E-05 4.00E-05 1.60E-04 1.00E+00'
  #   y = '0.00 1.28E-06 3.69E-06 5.87E-06 6.00E-06'
  # []
  [load_func]
    type = ADParsedFunction
    expression = 't*0.0002'
  []
[]

[BCs]
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = '3'
    value = 0
  []
  [ytop]
    type = ADFunctionDirichletBC
    boundary = '2'
    variable = disp_y
    function = load_func
  []
  [fix_x]
    type = ADDirichletBC
    variable = disp_x
    value = 0
    boundary = '4 5'
  []
  [fix_d]
    type = ADDirichletBC
    variable = d
    boundary = '2 3 4 5'
    value = 0
  []
[]

[Materials]
  [bulk_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'K'
    subdomain_to_prop_value = '1 ${K_epoxy}
                               2 ${K_pzt}'
  []
  [shear_modulus]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'G'
    subdomain_to_prop_value = '1 ${G_epoxy}
                               2 ${G_pzt}'
  []
  # [cnh]
  #   type = CNHIsotropicElasticity
  #   bulk_modulus = K
  #   shear_modulus = G
  #   phase_field = d
  #   degradation_function = g
  #   decomposition = NONE
  # []
  [small_deformation_elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
  []
  # [stress]
  #   type = ComputeLargeDeformationStress
  #   elasticity_model = cnh
  # []
  # [defgrad]
  #   type = ComputeDeformationGradient
  # []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = small_deformation_elasticity
    output_properties = 'stress'
  []
  [strain]
    type = ADComputeSmallStrain
  []
  # damage
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'l Gc'
    prop_values = '${l} ${Gc}'
  []
  # [no_deg] # no deg for testing
  #   type = NoDegradation
  #   phase_field = d 
  #   property_name = g
  #   expression = 1
  # []
  [degradation]
    type = RationalDegradationFunction
    phase_field = d
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd^2'
    phase_field = d
  []
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [psi]
    type = ADDerivativeParsedMaterial
    property_name = psi
    expression = 'g*psie+(Gc/c0/l)*alpha'
    coupled_variables = 'd'
    material_property_names = 'alpha(d) g(d) Gc c0 l psie(d)'
    derivative_order = 1
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0
  end_time = 1
  dtmin = 1e-10
  dtmax = 1e-2
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-3
    optimal_iterations = 50
    iteration_window = 10
    growth_factor = 5
  []
  petsc_options_iname = '-pc_type -snes_type   -pc_factor_shift_type -pc_factor_shift_amount'
  petsc_options_value = 'lu       vinewtonrsls NONZERO               1e-10'
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  # petsc_options_value = 'hypre boomeramg vinewtonrsls'
  automatic_scaling = true
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  line_search = None
  # [TimeIntegrator]
  #   type = NewmarkBeta
  #   inactive_tsteps = 1
  # []
[]

[Outputs]
  [exodus]
    type = Exodus
    min_simulation_time_interval = 1e-3
    simulation_time_interval = 1e-2
  []
  # simulation_time_interval = 1e-3
  print_linear_residuals = false
  file_base = './out/static'
  checkpoint = true
[]

# [Debug]
#   show_material_props = true
# []