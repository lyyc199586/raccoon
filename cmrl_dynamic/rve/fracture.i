[Mesh]
[]

[Variables]
  [d]
  []
[]

[AuxVariables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [bounds_dummy]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
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
    # block = 1
  []
  # [fixed]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = upper
  #   bound_value = 1e-4
  #   block = 2
  # []
[]

[Kernels]
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

[BCs]
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
  [Gc]
    type = ADPiecewiseConstantByBlockMaterial
    prop_name = 'Gc'
    subdomain_to_prop_value = '1 ${Gc_epoxy}
                               2 ${Gc_pzt}'
  []
  [cnh]
    type = CNHIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active'
  []
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'l'
    prop_values = '${l}'
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
  [degradation]
    type = RationalDegradationFunction
    phase_field = d
    property_name = g
    expression = (1-d)^p*(1-eta)+eta
    parameter_names = 'p eta '
    parameter_values = '2 1e-6'
  []
  [psi]
    type = ADDerivativeParsedMaterial
    property_name = psi
    expression = 'g*psie_active+(Gc/c0/l)*alpha'
    coupled_variables = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l psie(d)'
    derivative_order = 1
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  # petsc_options_iname = '-pc_type -snes_type'
  # petsc_options_value = 'asm      vinewtonrsls'
  # petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  # petsc_options_value = 'hypre boomeramg      vinewtonrsls '
  automatic_scaling = true
  

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
[]

[Outputs]
  print_linear_residuals = false
[]