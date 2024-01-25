# try only on elastic for now

# basalt properties (MPa, N, mm, s)
E = 20.11e3
nu = 0.24
Gc = 0.1
# sigma_ts = 11.31
# sigma_cs = 159.08
rho = 2.74e-9

K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'

# nucleation model
l = 3
# delta = 5

# model parameter
r = 25
a = 10 # load arc angle (deg)
p = 300
t0 = 100e-6 # ramp time
tf = 200e-6

[GlobalParams]
  displacements = 'disp_x disp_y'
  out_of_plane_strain = 'strain_zz'
  use_displaced_mesh = true
[]

[Mesh]
  [fmg]
  type = FileMeshGenerator
  file = '../mesh/disc_r25_h1.msh'
  []
  [left_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x < -${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'left_bnd'
    input = fmg
  []
  [right_bnd]
    type = ParsedGenerateSideset
    combinatorial_geometry = 'abs(x*x+y*y-25^2) < 1 & x > ${r}*cos(${a}/180*3.14)'
    new_sideset_name = 'right_bnd'
    input = left_bnd
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
  [d]
  []
  [fx]
  []
  [fy]
  []
  [accel_x]
  []
  [accel_y]
  []
  [vel_x]
  []
  [vel_y]
  []
  # [f_nu_var]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
[]

[Kernels]
  # [DynamicTensorMechanics]
  #   displacements = 'disp_x disp_y'
  # []
  # [solid_x]
  #   type = ADStressDivergenceTensors
  #   variable = disp_x
  #   component = 0
  #   save_in = fx
  # []
  # [solid_y]
  #   type = ADStressDivergenceTensors
  #   variable = disp_y
  #   component = 1
  #   save_in = fy
  # []
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
    # velocity = vel_x
    # acceleration = accel_x
  []
  [inertia_y]
    type = ADInertialForce
    variable = disp_y
    density = density
    # velocity = vel_y
    # acceleration = accel_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
    displacements = 'disp_x disp_y'
  []
[]

[Functions]
  [load]
    # type = ADParsedFunction
    type = ParsedFunction
    # expression = 'if(t<t0, p*sin(pi*t/2/t0), p)'
    expression = 'p*sin(pi*t/2/t0)'
    symbol_names = 'p t0'
    symbol_values = '${p} ${t0}'
  []
[]

[BCs]
  [fix_right_x]
    type = DirichletBC
    variable = disp_x
    boundary = right_bnd
    value = 0
  []
  # [load_left_x]
  #   type = Pressure
  #   variable = disp_x
  #   boundary = left_bnd
  #   function = load
  # []
  # [load_left_y]
  #   type = Pressure
  #   variable = disp_y
  #   boundary = left_bnd
  #   function = load
  # []
  [left_test]
    type = ADDirichletBC
    variable = disp_x
    boundary = left_bnd
    value = 0.1
  []
[]

[Materials]
  [bulk_properties]
    type = ADGenericConstantMaterial
    prop_names = 'E K G lambda l Gc density'
    prop_values = '${E} ${K} ${G} ${Lambda} ${l} ${Gc} ${rho}'
  []
  # [reg_density]
  #   type = MaterialADConverter
  #   ad_props_in = 'density'
  #   reg_props_out = 'reg_density'
  # []
  [nodegradation] # elastic test
    type = NoDegradation
    f_name = g 
    function = 1
    phase_field = d
  []
  # [degradation]
  #   type = PowerDegradationFunction
  #   f_name = g
  #   function = (1-d)^p*(1-eta)+eta
  #   phase_field = d
  #   parameter_names = 'p eta '
  #   parameter_values = '2 1e-5'
  # []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
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
    output_properties = 'psie_active'
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
  [Fy]
    type = NodalSum
    variable = fy
    boundary = left_bnd
    # outputs = 'pp exodus'
  []
  [Fx]
    type = NodalSum
    variable = fx
    boundary = left_bnd
    # outputs = 'pp exodus'
  []
[]

[Executioner]
  type = Transient
  solve_type = LINEAR
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []

  dtmin = 1e-10
  start_time = 0
  end_time = ${tf}

  [TimeStepper]
    type = FunctionDT
    function = 'if(t<5.8e-5, 1e-7, 0.5e-7)'
  []
[]

[Outputs]
  exodus = true
[]