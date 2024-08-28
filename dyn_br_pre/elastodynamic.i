# PMMA (see Michael Borden's PhD thesis, p132)
E = 32e3 # 32 GPa
nu = 0.2
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
rho = 2450
Gc = 3e-3 # N/mm -> 3 J/m^2

u0 = 0.0025
tf = 10
h = 1
l = 1

# hht parameters
hht_alpha = -0.3
# hht_alpha = 0
beta = '${fparse (1-hht_alpha)^2/4}'
gamma = '${fparse 1/2-hht_alpha}'

filebase = elastodyanmic_u${u0}_h${h}

[GlobalParams]
  displacements = 'disp_x disp_y'
  alpha = ${hht_alpha}
  gamma = ${gamma}
  beta = ${beta}
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './pre/pre_u${u0}_h${h}.e'
    use_for_exodus_restart = true
  []
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
  # [strain_zz]
  #   initial_from_file_var = 'strain_zz'
  #   initial_from_file_timestep = LATEST
  # []
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
[]

[BCs]
  [ytop]
    type = ADDirichletBC
    variable = disp_y
    boundary = top
    value = ${u0}
    # value = 0
  []
  [ybottom]
    type = ADDirichletBC
    variable = disp_y
    boundary = bottom
    value = -${u0}
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
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
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
  [strain]
    # type = ADComputePlaneSmallStrain
    type = ADComputeSmallStrain
    # out_of_plane_strain = 'strain_zz'
    displacements = 'disp_x disp_y'
    # output_properties = 'total_strain'
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

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist     '
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true

  line_search = none
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  nl_max_its = 100

  # dt = ${fparse t0*0.1}
  dt = ${fparse tf*0.1}
  # dt = ${fparse t0*0.005}
  # dt = ${t0}
  end_time = ${tf}

  # [TimeIntegrator]
  #   type = NewmarkBeta
  # []
[]

[Outputs]
  [exodus]
    # time_step_interval = ${fparse t0*0.1}
    # min_simulation_time_interval = ${fparse t0*0.05}
    type = Exodus
  []
  print_linear_residuals = false
  file_base = '${filebase}'
  time_step_interval = 1
[]