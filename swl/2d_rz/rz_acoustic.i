[Mesh]
   [./fmg]
     type = FileMeshGenerator
     file = '../mesh/2d/outer_vol_src.msh'
   [../]
[]


[Problem]
  coord_type = RZ
[]

[Variables]
  [p]
  []
  [disp_r]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [vel_r]
  []
  [vel_z]
  []
  [accel_r]
  []
  [accel_z]
  []
  # [I_r]
  # []
  # [I_z]
  # []
  # [acoustic_energy]
  #   # order = CONSTANT
  #   # family = MONOMIAL
  # []
[]

[Kernels]
  [inertia_p]
    type = InertialForce
    variable = p
  [../]
  [diff_p]
    type = ADCoefMatDiffusion
    variable = 'p'
    prop_names = 'Diff'
  [../]
  [source_p]
    type = ADCoefMatSource
    variable = p
    prop_names = 's'
    coefficient = -1
  []
  [inertia_r] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_r
    velocity = vel_r
    acceleration = accel_r
    density = water_density
    beta = 0.25 
    gamma = 0.5 
    eta = 0.0
  []
  [inertia_z] # M*accel + eta*M*vel
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    density = water_density
    beta = 0.25 
    gamma = 0.5 
    eta = 0.0
  []
  # [grad_p_r]
  #   type = PressureGradient
  #   variable = disp_r
  #   # displacements = 'disp_r disp_z'
  #   pressure = p
  #   component = 0
  # []
  # [grad_p_z]
  #   type = PressureGradient
  #   variable = disp_z
  #   # displacements = 'disp_r disp_z'
  #   pressure = p
  #   component = 1
  # []
[]


[AuxKernels]
  [accel_r]
    type = NewmarkAccelAux
    variable = accel_r
    displacement = disp_r
    velocity = vel_r
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_r]
    type = NewmarkVelAux
    variable = vel_r
    acceleration = accel_r
    gamma = 0.5
    execute_on = timestep_end
  []
  [accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = timestep_end
  []
  # [I_r]
  #   type = AcousticIntensity
  #   variable = I_r
  #   pressure = p
  #   velocity = vel_r
  #   execute_on = timestep_end
  # []
  # [I_z]
  #   type = AcousticIntensity
  #   variable = I_z
  #   pressure = p
  #   velocity = vel_z
  #   execute_on = timestep_end
  # []
  # [e]
  #   type = AcousticEnergy
  #   variable = acoustic_energy
  #   pressure = p
  #   vel_x = vel_r
  #   vel_y = vel_z
  #   density = Diff
  #   wavespeed = water_wavespeed
  # []
[]

[BCs]
  [axial_r]
    type = DirichletBC
    variable = disp_r
    boundary = axial
    value = 0
  []
[]
# [DiracKernels]
#   [./monopole_source]
#     type = DiracSource
#     variable = p
#     point = '0 1.75 0'
#     dim  = 2
#     #####################################
#     fL = 8.33e-2
#     t1 = 0.07
#     tRT = 0.01
#     tL  = 0.8
#     tP  = 1.0
#     p0  = 2.1e-8
#     # p0 = 5.26e-8
#     d1  = 9
#     upcoeff = 12.2189
#     downcoeff = 0.9404
#     num_shots = 1
#     #####################################
#     rho = 1e-3
#   [../]
# []

[Functions]
  [s_func]
    type = ParsedFunction
    value = 'r:=sqrt(x^2+(y-1-SD)^2);
            h:=(1 + tanh((t-t1)/tRT))*exp(-(t-t1)/tL)*cos(2*pi*fL*(t-t1) + pi/3);
            a0:=1 / tP * 4*pi / rho*c1/c2*p0*d1*max(h, 0.0)*1000*p_max;
            if(r<0.1, a0, 0)'
    vars = 'fL      t1   tRT  tL  tP  p0     d1 c1      c2     rho  p_max SD'
    vals = '8.33e-2 0.07 0.01 0.8 1.0 2.1e-8 9  12.2189 0.9404 1e-3 ${p_max} ${SD}'
  []
[]

[Materials]
  [density] # this is actually the coef = 1/rho/cf^2
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 444.44
  []
  [water_density] # rho
    type = GenericConstantMaterial
    prop_names = water_density
    prop_values = 1000
  []
  [water_wavespeed] # cf
    type = ADGenericConstantMaterial
    prop_names = water_wavespeed
    prop_values = 1.5
  []
  [diff] # this is actually the coef = 1/rho
    type = ADGenericConstantMaterial
    prop_names = 'Diff'
    prop_values = '1000'
  []
  [source]
    type = ADGenericFunctionMaterial
    prop_names = 's'
    prop_values = 's_func'
  []
[]

# [Postprocessors]
#   [total_acoustic_energy]
#     # type = ElementIntegralVariablePostprocessor
#     type = NodalSum
#     variable = acoustic_energy
#   []
#   [acoustic_energy_on_interface]
#     type = NodalSum
#     # type = SideIntegralVariablePostprocessor
#     variable = acoustic_energy
#     boundary = inner_BC
#   []
#   [acoustic_energy_on_top]
#     type = NodalSum
#     # type = SideIntegralVariablePostprocessor
#     variable = acoustic_energy
#     boundary = top
#   []
# []

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  # automatic_scaling = true
  end_time = 2.4
  dt = 1.5e-3
  # end_time = 1
  # dt = 1e-3
  [TimeIntegrator]
    type = NewmarkBeta
  []
[]

[Outputs]
  [./csv]
    type = CSV
    delimiter = ','
    file_base = 'acoustic_energy'
  [../]
  [./exodus]
    type = Exodus
    interval = 100
    file_base = fluid
  [../]
[]
