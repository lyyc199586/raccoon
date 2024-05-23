
# PMMA
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2.45e3
Gc = 3e-3 # N/mm -> 3 J/m^2
sigma_ts = 3.08 # MPa, sts and scs from guessing
psic = ${fparse sigma_ts^2/2/E}
p = 1
l = 1
r = 5

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  # use_displaced_mesh = true
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 20
    xmin = 0
    xmax = 100
    ymin = 0
    ymax = 20
  []
  [noncrack]
    type = BoundingBoxNodeSetGenerator
    input = gen 
    bottom_left = '49.5 -0.1 0'
    top_right = '100.1 0.1 0'
    new_boundary = noncrack
  []
  [initial_tip_circ]
    type = ParsedSubdomainMeshGenerator
    input = noncrack
    block_id = 1
    block_name = tip_circ 
    combinatorial_geometry = '(x-50)^2 + y^2 < ${r}^2'
  []
[]

[UserObjects]
  [moving_bnd]
    type = MovingNodeSetUserObject
    indicator = 'phi'
    criterion_type = ABOVE
    threshold = 0
    moving_boundary_name = noncrack
    execute_on = 'TIMESTEP_BEGIN'
    boundary = 'bottom'
  []
  [moving_circ]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'tip_var'
    criterion_type = BELOW
    threshold = 0
    subdomain_id = 1
    complement_subdomain_id = 0
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Functions]
  [moving]
    type = ParsedFunction
    expression = 'x-tip'
    symbol_names = 'tip'
    symbol_values = 'tip'
  []
  [tip_circ]
    type = ParsedFunction
    expression = '(x-tip)^2 + y^2 - r^2'
    symbol_names = 'tip r'
    symbol_values = 'tip ${r}'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [phi]
  []
  [tip_var]
  []
  [psie_var]
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  [fx]
  []
  [fy]
  []
  [d]
  []
[]

[BCs]
  [ytop]
    type = ADPressure
    variable = disp_y
    boundary = top
    function = '${p}'
    factor = -1
  []
  [noncrack]
    type = ADDirichletBC
    variable = disp_y
    value = 0
    boundary = 'noncrack'
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    save_in = fx
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
    density = density
    velocity = vel_x
    acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
    density = density
    velocity = vel_y
    acceleration = accel_y
  []
[]

[AuxKernels]
  [phi]
    type = FunctionAux
    variable = phi
    function = moving
    execute_on = 'TIMESTEP_BEGIN'
  []
  [tip_var]
    type = FunctionAux
    variable = tip_var
    function = tip_circ
    execute_on = 'TIMESTEP_BEGIN'
  []
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = timestep_end
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = timestep_end
  []
  [get_psie]
    type = ProjectionAux
    variable = psie_var
    v = psie
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density psic'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho} ${psic}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [crack_surface_density]
    type = CrackSurfaceDensity
    phase_field = d
  []
  [nodeg]
    type = NoDegradation
    property_name = g 
    phase_field = d
    expression = 1
  []
  [strain]
    type = ADComputeSmallStrain
    displacements = 'disp_x disp_y'
    output_properties = 'total_strain'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active psie psie_intact'
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
  [Jint]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left top right bottom'
    # density = density
  []
  # [max_psie]
  #   type = ADElementExtremeMaterialProperty
  #   mat_prop = psie
  #   value_type = max
  # []
  # [max_psie_var]
  #   type = NodalExtremeValue
  #   variable = psie_var
  # []
  # [max_psie_var_id]
  #   type = NodalMaxValueId
  #   variable = psie_var
  # []
  # [tip_x]
  #   type = NodalMaxValuePosition
  #   variable = psie_var
  #   component = 0
  #   boundary = noncrack
  # []
  [tip_adv]
    type = ParsedPostprocessor
    expression = 'if(Jint>Gc, 1, 0)'
    pp_names = 'Jint'
    constant_names = 'Gc'
    constant_expressions = '${Gc}'
  []
  [tip_cum]
    type = CumulativeValuePostprocessor
    postprocessor = tip_adv
  []
  [tip]
    type = ParsedPostprocessor
    expression = '50 + tip_cum'
    pp_names = 'tip_cum'
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    # constant_names = 'Gc'
    # constant_expressions = '${Gc}'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true

  dt = 1
  # num_steps = 2
  start_time = 0
  end_time = 100
[]

[Outputs]
  exodus = true
  file_base = './out/moving'
  [csv]
    type = CSV
    file_base = './gold/moving'
  []
[]