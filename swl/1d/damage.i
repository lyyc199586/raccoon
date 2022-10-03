# Begostone
E = 0.02735
# nu = 0.2
nu = 0
Gc_base = 21.88e-9
# Gc_base = 1e-40
gc_ratio = 1
l_base = 0.1
psic_base = 7.0e-9
psic_ratio = 1
# psic = 1e-40
k = 1e-09
# alphaT = 8.0e-9
# SD = 1
p_max = 1e-9
alphaT = 1.0
rho_s = 1.995e-3

###############################################################################
l_ratio = '${fparse gc_ratio/psic_ratio}'
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Gc = '${fparse Gc_base*gc_ratio}'
psic = '${fparse psic_base*psic_ratio}'
l = '${fparse if(l_ratio>1, l_base, l_base*l_ratio)}'
###############################################################################

[Problem]
  # coord_type = RZ
  coord_type = XYZ
[]

[MultiApps]
  [elastodynamic]
    type = TransientMultiApp
    input_files = 'elastic.i'
    app_type = raccoonApp
    execute_on = 'TIMESTEP_BEGIN'
    cli_args = 'G=${G};K=${K};Gc=${Gc};l=${l};psic=${psic};rho_s=${rho_s};p_max=${p_max};gc_ratio=${gc_ratio}'
  []
[]

[Transfers]
  [to_d] # pass d to elastodynamic
    type = MultiAppCopyTransfer
    multi_app = 'elastodynamic'
    direction = to_multiapp
    source_variable = 'd'
    variable = 'd'
  []
  [from_psie_active] # get psie_active from elastodynamic
    type = MultiAppCopyTransfer
    multi_app = 'elastodynamic'
    direction = from_multiapp
    source_variable = 'psie_active'
    variable = 'psie_active'
  []
[]

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 200
    ny = 50
    xmin = 2
    xmax = 4
    ymin = 0
    ymax = 0.5
  []
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
  [alpha_bar]
    order = CONSTANT
    family = MONOMIAL
  []
  [f_alpha]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Bounds]
  [irreversibility]
    type = VariableOldValueBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    bound_type = lower
  []
  [upper]
    type = ConstantBoundsAux
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    bound_type = upper
    bound_value = 1
  []
[]

[Kernels]
  [diff]
    type = ADPFFDiffusion
    variable = 'd'
    fracture_toughness = Gc_deg
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
  [f_alpha]
    type = ADMaterialRealAux
    property = 'f_alpha'
    variable = 'f_alpha'
    execute_on = 'TIMESTEP_END'
  []
  [alpha_bar]
    type = ADMaterialRealAux
    property = 'alpha_bar'
    variable = 'alpha_bar'
    execute_on = 'TIMESTEP_END'
  []
[]

[Materials]
  [fracture_properties]
    type = ADGenericConstantMaterial
    prop_names = 'Gc l psic'
    prop_values = '${Gc} ${l} ${psic}'
  []
  [degradation]
    type = RationalDegradationFunction
    f_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1.0 0.0 1e-3'
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
    function = 'alpha*Gc_deg/c0/l+g*psie_active'
    args = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc_deg c0 l'
    derivative_order = 1
  []
  [Gc_deg]
    type = ADParsedMaterial
    f_name = Gc_deg
    function = 'f_alpha*Gc'
    material_property_names = 'f_alpha Gc'
  []
  [fatigue_mobility]
    type = ComputeFatigueDegradationFunction
    elastic_energy_var = psie_active
    f_alpha_type = 'asymptotic'
    alpha_T = ${alphaT}
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -sub_pc_type -ksp_max_it -ksp_gmres_restart -sub_pc_factor_levels -snes_type'
  petsc_options_value = 'asm      ilu          200         200                0                     vinewtonrsls'
  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-06
  automatic_scaling = true
  end_time = 2.2
  # end_time = 2.5
  dt = 0.5e-3
[]

[Outputs]
  exodus = true
  interval = 10
  file_base = 'damage'
[]

