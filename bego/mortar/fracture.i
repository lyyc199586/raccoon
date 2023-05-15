[Mesh]
  coord_type = XYZ
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/disk_2d_h0.01.msh'
    ### for recover
    # use_for_exodus_restart = true
    # file = './out/solid_R14.5_ts10_cs80_l0.25_delta25.e'
  []
[]

# [Adaptivity]
#   initial_marker = initial
#   initial_steps = 3
#   max_h_level = 3
#   stop_time = 0
#   [Markers]
#     [initial]
#       type = BoxMarker
#       bottom_left = '-1 -3 0'
#       top_right = '1 3 0'
#       inside = REFINE
#       outside = DO_NOTHING
#     []
#   []
# []

[Problem]
  coord_type = XYZ
  # type = FEProblem
  # solve = False
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables]
  [d]
    # [InitialCondition]
    #   type = FunctionIC
    #   function = 'if(x=0&x>=-0.5&x<=0.5,1,0)'
    # []
    # initial_from_file_var = 'd' # for restart
    # initial_from_file_timestep = LATEST # for restart
  []
[]

[AuxVariables]
  [bounds_dummy]
  []
  [disp_x]
  []
  [disp_y]
  []
  # [strain_zz]
  # []
  [psie_active]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_nu_var]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  [conditional]
    type = ConditionalBoundsAux
    variable = bounds_dummy
    bounded_variable = d
    fixed_bound_value = 0
    threshold_value = 0.95
  []
  # [upper_fixed]
  #   type = ConstantBoundsAux
  #   variable = bounds_dummy
  #   bounded_variable = d
  #   bound_type = upper
  #   bound_value = 0
  #   # bound_value = 0.1 # prevent damage
  # []
  [upper]
    type = ConstantBoundsAux
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
  [nuc_force]
    type = ADCoefMatSource
    variable = d
    prop_names = 'ce'
  []
[]

[AuxKernels]
  [get_f_nu]
    type = ADMaterialRealAux
    property = f_nu
    variable = f_nu_var
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda Gc l'
    prop_values = '${E} ${K} ${G} ${Lambda} ${Gc} ${l}'
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  [nodegradation]
    type = NoDegradation
    f_name = g
    function = 1
    phase_field = d
  []
  [crack_geometric]
    type = CrackGeometricFunction
    f_name = alpha
    function = 'd'
    phase_field = d
  []
  [psi]
    type = ADDerivativeParsedMaterial
    f_name = psi
    function = 'g*psie_active+(Gc/c0/l)*alpha'
    args = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc c0 l'
    derivative_order = 1
  []
  [kumar_material]
    type = LinearNucleationMicroForce2021
    phase_field = d
    if_stress_intact = false
    stress_name = stress
    normalization_constant = c0
    tensile_strength = '${sigma_ts}'
    compressive_strength = '${sigma_cs}'
    delta = '${delta}'
    external_driving_force_name = ce
    stress_balance_name = f_nu
    output_properties = 'ce f_nu'
    # outputs = exodus
  []
  [strain]
    type = ADComputeSmallStrain
    # type = ADComputePlaneSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    # decomposition = VOLDEV
    # output_properties = 'psie'
    # outputs = exodus
  []
  [stress]
    type = ComputeSmallDeformationStress
    elasticity_model = elasticity
    output_properties = 'stress'
    # outputs = exodus
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -snes_type'
  petsc_options_value = 'lu       superlu_dist                  vinewtonrsls'
  # petsc_options_iname = '-pc_type -pc_hypre_type -snes_type '
  # petsc_options_value = 'hypre boomeramg      vinewtonrsls'
  automatic_scaling = true

  line_search = bt

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-6
  # nl_abs_tol = 1e-8

  ### restart
  # start_time = 0.492
  # end_time = 0.6
  # dt = 2e-3
[]

# [Outputs]
#   [exodus]
#     type = Exodus
#     interval = 1
#   []
#   file_base = './out/flat/fracture_ts${sigma_ts}_cs${sigma_cs}_l${l}_delta${delta}'
#   print_linear_residuals = false
# []
