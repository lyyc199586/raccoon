# [Mesh]
#   # [fmg]
#   #   type = FileMeshGenerator
#   #   file = './mesh/kal.msh'
#   # []
#   [gen] #h_c = 1, h_r = 0.25
#     type = GeneratedMeshGenerator
#     dim = 2
#     nx = 20
#     ny = 20
#     xmin = 0
#     xmax = 100
#     ymin = 0
#     ymax = 100
#   []
#   [sub_upper]
#     type = ParsedSubdomainMeshGenerator
#     input = gen
#     combinatorial_geometry = 'x < 50 & y > 25 & y < 50'
#     block_id = 1
#   []
#   [sub_lower]
#     type = ParsedSubdomainMeshGenerator
#     input = sub_upper
#     combinatorial_geometry = 'x < 50 & y < 25'
#     block_id = 2
#   []
#   [split]
#     input = sub_lower
#     type = BreakMeshByBlockGenerator
#     block_pairs = '1 2'
#     split_interface = true
#   []
# []

[Mesh] # cloned from the parent app
[]

[Adaptivity]
  # initial_marker = initial_box
  # initial_steps = ${refine}
  marker = combo_marker
  max_h_level = ${refine}
  cycles_per_step = ${refine}
  [Markers]
    [initial_box]
      type = BoxMarker
      bottom_left = '44 19 0'
      top_right = '56 31 0'
      inside = refine
      outside = DO_NOTHING
    []
    [damage_marker]
      type = ValueRangeMarker
      variable = d
      lower_bound = 0.0001
      upper_bound = 1
    []
    [psie_marker]
      type = ValueThresholdMarker
      variable = psie_active
      refine = 3
    []
    [combo_marker]
      type = ComboMarker
      markers = 'initial_box damage_marker'
    []
  []
[]

[Variables]
  [d]
  []
[]

[AuxVariables]
  [bounds_dummy]
  []
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
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
  # [conditional]
  #   type = ConditionalBoundsAux
  #   variable = 'bounds_dummy'
  #   bounded_variable = 'd'
  #   fixed_bound_value = 0
  #   threshold_value = 0.95
  # []
  [upper]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1
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
  # [nuc_force]
  #   type = ADCoefMatSource
  #   variable = d
  #   prop_names = 'ce'
  # []
[]

# [AuxKernels]
#   [get_f_nu]
#     type = ADMaterialRealAux
#     property = f_nu
#     variable = f_nu_var
#   []
# []

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l} ${psic}'
  []
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1 0 1e-9'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [psi]
    type = ADDerivativeParsedMaterial
    property_name = psi
    expression = 'g*psie_active+(Gc/c0/l)*alpha'
    coupled_variables = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [psi_f]
    type = ADParsedMaterial
    property_name = psi_f
    expression = '(Gc/c0/l)*alpha'
    coupled_variables = 'd'
    material_property_names = 'alpha(d) Gc c0 l'
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    # decomposition = SPECTRAL
    # decomposition = VOLDEV
    decomposition = NONE
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
  []
[]

[Postprocessors]
  [Psi_f]
    type = ADElementIntegralMaterialProperty
    mat_prop = psi_f
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  # petsc_options_iname = '-pc_type  -pc_hypre_type -snes_type'
  # petsc_options_value = 'hypre      boomeramg                  vinewtonrsls'
  # petsc_options_iname = '-pc_type -snes_type'
  # petsc_options_value = 'asm      vinewtonrsls'
  # petsc_options_iname = '-pc_type -sub_pc_type -ksp_max_it -ksp_gmres_restart -sub_pc_factor_levels -snes_type'
  # petsc_options_value = 'asm      ilu          200         200                0                     vinewtonrsls'
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # [TimeStepper]
  #   type = FunctionDT
  #   function = 'if(t <= 3.1e-5, 5e-7, 5e-8)'
  #   # type = ConstantDT
  #   # dt = 5e-7
  #   cutback_factor_at_failure = 0.5
  # []
[]

[Outputs]
  csv = true
[]
