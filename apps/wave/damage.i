[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 2000
  ny = 1
  nz = 1
  xmin = 0.0
  xmax = 1000
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 1
[]

[Variables]
  [d]
  []
[]

[AuxVariables]
  [bounds_dummy]
  []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [ce]
    order = CONSTANT
    family = MONOMIAL
  []
  [d_max]
  []
[]

[Bounds]
  # [irreversibility]
  #   type = VariableOldValueBoundsAux
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = lower
  # []
  [conditional]
    type = ConditionalBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    fixed_bound_value = 0
    threshold_value = 0.95
  []
  [upper]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 0.1052
  []
[]

[Kernels]
  [diff]
    type = ADPFFDiffusion
    variable = d
    fracture_toughness = Gc
    regularization_length = l
    normalization_constant = c0
  []
  [source]
    type = ADPFFSource
    variable = d
    free_energy = psi
  []
[]

[AuxKernels]
  [hist]
    type = HistoryField
    variable = d_max
    source = d
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  [degradation]
    type = PowerDegradationFunction
    f_name = g
    function = (1-d)^p*(1-eta)+eta
    phase_field = d
    parameter_names = 'p eta '
    parameter_values = '2 0'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  # [psi] # brittle ?
  #   type = ADDerivativeParsedMaterial
  #   f_name = psi
  #   function = 'alpha*Gc/c0/l+g*psie_active'
  #   args = 'd psie_active'
  #   material_property_names = 'alpha(d) g(d) Gc c0 l'
  #   derivative_order = 1
  # []
  [psi] # kumar
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(ce+Gc/c0/l)*alpha'
    args = 'd psie_active ce'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  # petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_max_it -ksp_gmres_restart -sub_pc_factor_levels -snes_type'
  petsc_options_value = 'asm      ilu          200         200                0                     vinewtonrsls'
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-9
  # nl_abs_tol = 1e-11

  # solve_type = PJFNK
  # petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = 'asm      31                  preonly       lu           1'

  # l_max_its = 20
  # nl_max_its = 20
  
  # l_tol = 1e-9
[]

[Outputs]
  print_linear_residuals = false
[]

