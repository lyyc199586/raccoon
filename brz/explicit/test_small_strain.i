[GlobalParams]
  displacements = 'disp_x disp_y'
  # implicit = false
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 2
    ny = 2
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

[Kernels]
  [solid_x]
    type = ADDynamicStressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_y]
    type = ADDynamicStressDivergenceTensors
    variable = disp_y
    component = 1
  []
  [inertia_x]
    type = InertialForce
    variable = disp_x
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
  []
  [plane_stress]
    type = ADWeakPlaneStress
    variable = 'strain_zz'
  []
[]

[BCs]
  [fix_right]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0.0
  []
  [load_left]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.01
  []
[]

[Materials]
  [elasticity]
    type = ADComputeIsotropicElasticityTensor
    poissons_ratio = 0.24
    youngs_modulus = 20e3
  []
  [stress_block]
    type = ADComputeLinearElasticStress
    output_properties = 'stress'
    outputs = exodus
  []
  [strain]
    type = ADComputePlaneSmallStrain
    out_of_plane_strain = 'strain_zz'
    output_properties = 'mechanical_strain'
    outputs = exodus
  []
  [density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 2.74e-9
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 1e-7
  dt = 1e-8

  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []
[]

[Outputs]
  exodus = true
[]
