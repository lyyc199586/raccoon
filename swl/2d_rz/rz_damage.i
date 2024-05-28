# Begostone
E = 0.02735
nu = 0.2
Gc_base = 21.88e-9
gc_ratio = 1
l = 0.1 # h = 0.02
psic0 = 7.0e-9
# psic0 = 3.15e-9
# k = 1e-09
alphaT = 1000 # disable fatigue
# alphaT = 0.02
SD = 0.75
# SD = 0.5
p_max = 1
# alphaT = 1.0
rho_s = 1.995e-3
p_f = 1 # paramter in fatigue degradation

# Glass
# E = 0.0625
# nu = 0.19
# Gc_base = 1.6e-8
# gc_ratio = 1
# l = 0.1
# psic = 2e-8
# k = 1e-09
# # alphaT = 8.0e-9
# SD = 0.75
# p_max = 4
# alphaT = 1.0
# rho_s = 2.2e-3
###############################################################################
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Gc = '${fparse Gc_base*gc_ratio}'
###############################################################################

[MultiApps]
  [elastodynamic]
    type = TransientMultiApp
    input_files = 'rz_elastic.i'
    app_type = raccoonApp
    execute_on = 'TIMESTEP_BEGIN'
    cli_args = 'G=${G};K=${K};Gc=${Gc};l=${l};psic0=${psic0};rho_s=${rho_s};SD=${SD};p_max=${p_max};p_f=${p_f};alphaT=${alphaT}'
  []
[]

[Transfers]
  [to_d]
    type = MultiAppCopyTransfer
    to_multi_app = 'elastodynamic'
    source_variable = 'd'
    variable = 'd'
  []
  [from_psie_active]
    type = MultiAppCopyTransfer
    from_multi_app = 'elastodynamic'
    source_variable = 'psie_active'
    variable = 'psie_active'
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../mesh/2d/inner.msh'
  []
  coord_type = RZ
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
    type = VariableOldValueBounds
    variable = 'bounds_dummy'
    bounded_variable = 'd'
    bound_type = lower
  []
  [upper]
    type = ConstantBounds
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
    prop_names = 'Gc l psic0'
    prop_values = '${Gc} ${l} ${psic0}'
  []
  [degradation]
    type = RationalDegradationFunction
    property_name = g
    phase_field = d
    material_property_names = 'Gc psic xi c0 l'
    parameter_names = 'p a2 a3 eta'
    parameter_values = '2 1.0 0.0 1e-3'
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
    expression = 'alpha*Gc_deg/c0/l+g*psie_active'
    coupled_variables = 'd psie_active'
    material_property_names = 'alpha(d) g(d) Gc_deg c0 l'
    derivative_order = 1
  []
  [Gc_deg]
    type = ADParsedMaterial
    property_name = Gc_deg
    expression = 'f_alpha*Gc'
    material_property_names = 'f_alpha Gc'
  []
  [psic_deg]
    type = ADParsedMaterial
    property_name = psic
    expression = 'f_alpha*psic0'
    material_property_names = 'f_alpha psic0'
  []
  [fatigue_mobility]
    type = ComputeFatigueDegradationFunction
    elastic_energy_var = psie_active
    energy_threshold = psic0
    f_alpha_type = 'asymptotic'
    alpha_T = ${alphaT}
    p = ${p_f}
    # k = 0.02
    k = 0
  []
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    variable = 'd psie_active alpha_bar f_alpha'
    start_point = '0 1 0'
    end_point = '3.25 1 0'
    num_points = 200
    sort_by = x
    outputs = csv
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
  end_time = 2.1
  dt = 0.75e-3
[]

[Outputs]
  exodus = true
  time_step_interval = 100
  # sync_times = 2.4
  # file_base = './out/sd${SD}_p${p_f}_k0.02/damage_1'
  file_base = './out/sd${SD}/damage_1'
  [csv]
    type = CSV
    # sync_only = true
    time_step_interval = 100
    # sync_times = 2.1
    file_base = './gold/sd${SD}_p${p_f}_k0.02/np_1'
    enable = false
  []
[]

