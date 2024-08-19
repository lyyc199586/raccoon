# unit: N, MPa, mm, ms

G = 31.44e-3 # MPa
K = '${fparse 10*G}'

u = 4.5
cw = 2
# u = 9
# u = 1
# u = 27
rho = 1e-3
# h = 0.5
h = 0.25
# refine = 1

# hht parameters
hht_alpha = -0.3
# hht_alpha = 0
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

filebase = free_elastodynamic_cw${cw}_u${u}_h${h}

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'pre_free_cw${cw}_u${u}_h${h}.e'
    use_for_exodus_restart = true
  []
  # [crack_region]
  #   type = ParsedSubdomainMeshGenerator
  #   input = fmg
  #   combinatorial_geometry = 'abs(y) <= 4'
  #   block_id = 1
  # []
  # [refine]
  #   type = RefineBlockGenerator
  #   block = 1
  #   input = crack_region
  #   refinement = ${refine}
  # []
[]

[Variables]
  [disp_x]
    initial_from_file_var = 'disp_x'
    initial_from_file_timestep = LATEST
  []
  [disp_y]
    initial_from_file_var = 'disp_y'
    initial_from_file_timestep = LATEST
  []
  [strain_zz]
    initial_from_file_var = 'strain_zz'
    initial_from_file_timestep = LATEST
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
  [fx]
  []
  [fy]
  []
  [d]
  []
  [F]
    order = CONSTANT
    family = MONOMIAL
  []
  [s1]
    order = CONSTANT
    family = MONOMIAL
  []
  [s2]
    order = CONSTANT
    family = MONOMIAL
  []
  [s3]
    order = CONSTANT
    family = MONOMIAL
  []
  [hoop]
    order = CONSTANT
    family = MONOMIAL
  []
  [vms]
    order = CONSTANT
    family = MONOMIAL
  []
  [hydrostatic]
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
    use_displaced_mesh = true
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [vel_x] 
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    execute_on = 'TIMESTEP_BEGIN TIMESTEP_END'
  []
  [s1]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s1
    scalar_type = MaxPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s2]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s2
    scalar_type = MidPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [s3]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = s3
    scalar_type = MinPrincipal
    execute_on = 'TIMESTEP_END'
  []
  [hoop]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hoop
    scalar_type = HoopStress
    execute_on = 'TIMESTEP_END'
  []
  [hydrostatic]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = hydrostatic
    scalar_type = Hydrostatic
    execute_on = 'TIMESTEP_END'
  []
  [vms]
    type = ADRankTwoScalarAux
    rank_two_tensor = stress
    variable = vms
    scalar_type = VonMisesStress
    execute_on = 'TIMESTEP_END'
  []
  [F]
    type = ADRankTwoAux
    variable = F
    rank_two_tensor = deformation_gradient
    index_i = 1
    index_j = 1
  []
[]

[BCs]
  [ytop]
    type = ADDirichletBC
    variable = disp_y
    boundary = top
    value = ${u}
    # value = 0
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = bottom
    value = -${u}
    # value = 0
  []
  [xtop]
    type = ADDirichletBC
    variable = disp_x
    boundary = top
    value = 0
  []
  [xbottom]
    type = ADDirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'K G density'
    prop_values = '${K} ${G} ${rho}'
  []
  [crack_geometric]
    type = CrackGeometricFunction
    property_name = alpha
    expression = 'd'
    phase_field = d
  []
  [nodeg]
    type = NoDegradation
    property_name = g
    phase_field = d
  []
  [cnh]
    type = CNHIsotropicElasticity
    bulk_modulus = K
    shear_modulus = G
    phase_field = d
    degradation_function = g
  []
  [stress]
    type = ComputeLargeDeformationStress
    elasticity_model = cnh
    output_properties = 'stress'
    outputs = 'exodus'
  []
  [defgrad]
    type = ComputePlaneDeformationGradient
    out_of_plane_strain = strain_zz
  []
[]

[Postprocessors]
  [Fy_top]
    type = NodalSum
    variable = fy
    boundary = top
  []
  [J]
    type = PhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    # outputs = "csv exodus"
  []
  [DJ1]
    type = DynamicPhaseFieldJIntegral
    J_direction = '1 0 0'
    strain_energy_density = psie
    displacements = 'disp_x disp_y'
    boundary = 'left bottom right top'
    density = density
    # outputs = "csv exodus"
  []
  [DJ2]
    type = DJint
    J_direction = '1 0 0'
    displacements = 'disp_x disp_y'
    velocities = 'vel_x vel_y'
    density = density
  []
  [DJint]
    type = ParsedPostprocessor
    expression = 'DJ1 + DJ2'
    pp_names = 'DJ1 DJ2'
  []
  [KE]
    type = KineticEnergy
  []
  [SE]
    type = ADElementIntegralMaterialProperty
    mat_prop = psie
  []
  [EW]
    type = ExternalWork
    boundary = 'top bottom'
    forces = 'fx fy'
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'hypre       boomeramg                 '
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist                 '
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'asm'
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  # nl_rel_tol = 1e-4
  # nl_abs_tol = 1e-6

  # dt = 5e-7
  # end_time = 100e-6
  dt = 5e-1
  end_time = 2
  
[]

[Outputs]
  [exodus]
    type = Exodus
  []
  # checkpoint = true
  print_linear_residuals = false
  file_base = './out/${filebase}'
  time_step_interval = 1
[]