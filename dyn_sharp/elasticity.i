# Homalite-100
E = 4550 # MPa
nu = 0.31
rho = 1230
# Gc = 0.0426 # N/mm

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

refine = 2 # 2 -> 0.5
p0 = 5
# p0 = 30
# p0 = 62
T0 = 25
Tf = 100

# crack length
# a = 100
# a = 102.5
a = 105

#
filename = 'sharp_a${a}_p${p0}'

# hht parameters
hht_alpha = -0.3
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
  use_displaced_mesh = false
[]

[Mesh]
  [gen] #h_c = 2, h_r = 0.5
    type = GeneratedMeshGenerator
    dim = 2
    nx = 250
    ny = 150
    xmin = 0
    xmax = 500
    ymin = -150
    ymax = 150
  []
  [crack_region]
    input = gen
    type = SubdomainBoundingBoxGenerator
    bottom_left = '-0.1 -2.1 -0.1'
    top_right = '${fparse a+2.1} 2.1 0.1'
    block_id = '1'
  []
  [refine]
    input = crack_region
    type = RefineBlockGenerator
    block = '1'
    refinement = ${refine}
  []
  [sub_upper]
    type = ParsedSubdomainMeshGenerator
    input = refine
    combinatorial_geometry = 'x < ${a} & y > 0'
    block_id = 2
  []
  [sub_lower]
    type = ParsedSubdomainMeshGenerator
    input = sub_upper
    combinatorial_geometry = 'x < ${a} & y < 0'
    block_id = 3
  []
  [split] # split 2 blocks, generate 2 (current) crack surface: Block2_Block3 (upper) and Block3_Block2 (lower)
    input = sub_lower
    type = BreakMeshByBlockGenerator
    block_pairs = '2 3'
    split_interface = true
    add_interface_on_two_sides = true
  []
  [initial_upper_crack] # we need the initial crack face to enforce pressure bc
    input = split
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x <= 100'
    included_boundaries = 'Block2_Block3'
    new_sideset_name = 'initial_upper_crack'
  []
  [initial_lower_crack]
    input = initial_upper_crack
    type = ParsedGenerateSideset
    combinatorial_geometry = 'x <= 100'
    included_boundaries = 'Block3_Block2'
    new_sideset_name = 'initial_lower_crack'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [strain_zz]
  []
[]

[AuxVariables]
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  [vel_z]
  []
  [fx]
  []
  [fy]
  []
  [d] # dummy var
  []
  [k_var]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
    save_in = fx
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
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[AuxKernels]
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
  [kinetic_energy_aux]
    type = ADKineticEnergyAux
    variable = k_var
    newmark_velocity_x = vel_x
    newmark_velocity_y = vel_y
    newmark_velocity_z = vel_z
    density = density
  []
[]

[Functions]
  [p_func]
    type = PiecewiseLinear
    x = '0 ${T0} ${Tf}'
    y = '0 ${p0} ${p0}'
  []
[]
[BCs]
  [y_upper]
    type = ADPressure
    variable = disp_y
    boundary = initial_upper_crack
    function = p_func
  []
  [y_lower]
    type = ADPressure
    variable = disp_y
    boundary = initial_lower_crack
    function = p_func
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${rho}'
  []
  [no_deg] # dummy
    type = NoDegradation
    phase_field = d
    expression = 1
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
  []
  [elasticity]
    type = SmallDeformationIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
    decomposition = NONE
    output_properties = 'psie_active psie'
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
  [kinetic_energy]
    type = KineticEnergy
  []
  [strain_energy]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [external_work]
    type = ExternalWork
    boundary = 'initial_lower_crack initial_upper_crack'
    forces = 'fx fy'
  []
  [potenial_energy]
    type = ParsedPostprocessor
    expression = 'strain_energy - external_work'
    pp_names = 'strain_energy external_work'
  []
  [Fy_lower]
    type = NodalSum
    variable = fy
    boundary = initial_lower_crack
  []
  [Fy_upper]
    type = NodalSum
    variable = fy
    boundary = initial_upper_crack
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  automatic_scaling = true
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  nl_max_its = 200

  dt = 1
  end_time = ${Tf}
[]

[Outputs]
  [exodus]
    type = Exodus
    min_simulation_time_interval = 0.5
  []
  # checkpoint = true
  print_linear_residuals = false
  file_base = './out/${filename}'
  time_step_interval = 1
  [csv]
    file_base = './gold/${filename}'
    type = CSV
  []
[]