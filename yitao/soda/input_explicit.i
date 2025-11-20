E = 72e3
nu = 0.25
rho = 2.44e-9
K = '${fparse E/3/(1-2*nu)}'
G = '${fparse E/2/(1+nu)}'
Gc = 9e-3  #kN/m or kJ/m^2
lambda = '${fparse E*nu/(1+nu)/(1-2*nu)}'
c = '${fparse sqrt((K+4/3*G)/rho)}'

sigma_ts = 30 # MPa
sigma_cs = 330
sigma_hs = '${fparse 2/3*sigma_ts*sigma_cs/(sigma_cs - sigma_ts)}'
p = 22.576

E_p = 1.7
nu_p = 0.4
rho_p = 1e-9
K_p = '${fparse E_p/3/(1-2*nu_p)}'
G_p = '${fparse E_p/2/(1+nu_p)}'

# lch = 3*E*Gc/(8sts^2)=0.27, hf=0.1
l = 0.25

k = 1
Md = '${fparse Gc*l/c/c}'
# mobility = '${fparse c/(2*sqrt(2*Gc*l*k))}'
# Cd = '${fparse 1/mobility}'


[GlobalParams]
    displacements = 'disp_x disp_y'
[]

[Problem]
    extra_tag_matrices = 'mass damping'
[]

[Mesh]
    [gen]
      type = FileMeshGenerator
      file = './mesh.msh'
    []
    [toplayer]
      type = ParsedSubdomainMeshGenerator
      input = gen
      combinatorial_geometry = 'y > 74'
      block_id = 1
      block_name = top_layer
    []
    [noncrack]
      type = BoundingBoxNodeSetGenerator
      input = toplayer
      new_boundary = noncrack
      bottom_left = '26.9 0 0'
      top_right = '100.1 0 0'
    []
    [vpartialtop]
      type = ParsedGenerateSideset
      input = noncrack
      # included_boundaries = 'v-partial'
      included_boundaries = 'v-entire'
      new_sideset_name = 'v-load'
      combinatorial_geometry = 'x < 13.6'
    []
    construct_side_list_from_node_list = true
[]

[Variables]
    [disp_x]
    []
    [disp_y]
    []
    [d]
        # [InitialCondition]
        #     type = FunctionIC
        #     function = 'if(y>=0&y<=0.25&x>=0&x<=20,1,0)'
        # []
    []
[]

[AuxVariables]
    [fx]
    []
    [fy]
    []
[]

[Kernels]
    [inertia_x]
        type = MassMatrix
        variable = disp_x
        density = ${rho}
        matrix_tags = 'mass'
        block = 0
    []
    [inertia_x_putty]
        type = MassMatrix
        variable = disp_x
        density = density_p
        matrix_tags = 'mass'
        block = 1
    []
    [solid_x]
        type = ADStressDivergenceTensors
        variable = disp_x
        component = 0
        save_in = fx
    []
    [inertia_y]
        type = MassMatrix
        variable = disp_y
        density = ${rho}
        matrix_tags = 'mass'
        block = 0
    []
    [inertia_y_putty]
        type = MassMatrix
        variable = disp_y
        density = density_p
        matrix_tags = 'mass'
        block = 1
    []
    [solid_y]
        type = ADStressDivergenceTensors
        variable = disp_y
        component = 1
        save_in = fy
    []
    [d_propagation]
        type = MassMatrix
        variable = d
        density = '${Md}'
        matrix_tags = 'mass'
    []
    [d_damping]
        type = MassMatrix
        variable = d
        # density = ${Cd}
        density = M_inv
        matrix_tags = 'damping'
    []
    [d_diff]
        type = ADPFFDiffusion
        variable = d
        fracture_toughness = Gc_delta
        regularization_length = l
        normalization_constant = c0
    []
    [d_source]
        type = ADPFFSource
        variable = d
        free_energy = psi
    []
    [nuc_force]
      type = ADCoefMatSource
      variable = d
      prop_names = 'ce'
      coefficient = 1
    []
[]

[Functions]
    [p_func] # trapezoidal loading pulse
      type = PiecewiseLinear
      x = '0 17.5e-6 57.5e-6 75e-6'
      y = '0 ${p}   ${p}   0'
    []
[]

[BCs]
    # [fix_top_x]
    #   type = ExplicitDirichletBC
    #   variable = disp_x
    #   boundary = top
    #   value = 0
    # []
    # [fix_top_y]
    #   type = ExplicitDirichletBC
    #   variable = disp_y
    #   boundary = top
    #   value = 0
    # []
    # [fix_center_y]
    #   type = ExplicitDirichletBC
    #   variable = disp_y
    #   boundary = noncrack
    #   value = 0
    # []
    [pressue_x]
      type = ADPressure
      # component = 0
      variable = disp_x
      displacements = 'disp_x disp_y'
      boundary = 'v-load'
      function = p_func
    []
    [pressue_y]
      type = ADPressure
      # component = 1
      variable = disp_y
      displacements = 'disp_x disp_y'
      boundary = 'v-load'
      function = p_func
    []
[]

[Materials]
    [bulk]
        type = ADGenericConstantMaterial
        prop_names = 'E K G Gc lambda l density sigma_ts sigma_cs sigma_hs c k'
        prop_values = '${E} ${K} ${G} ${Gc} ${lambda} ${l} ${rho} ${sigma_ts} ${sigma_cs} ${sigma_hs} ${c} ${k}'
    []
    [crack_geometric]
        type = CrackGeometricFunction
        property_name = alpha
        expression = 'd'
        phase_field = d
    []
    [degradation]
        type = PowerDegradationFunction
        property_name = g
        expression = (1-d)^p*(1-eta)+eta
        phase_field = d
        parameter_names = 'p eta '
        parameter_values = '2 1e-6'
    []
    [strain]
        type = ADComputeSmallStrain
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
    [density_putty]
      type = GenericConstantMaterial
      prop_names = 'density_p'
      prop_values = '${rho_p}'
      block = 1
    []
    [strain_putty]
      type = ADComputeSmallStrain
      block = 1
    []
    [elasticity_putty]
      type = ADComputeIsotropicElasticityTensor
      bulk_modulus = ${K_p}
      shear_modulus = ${G_p}
      block = 1
    []
    [stress_putty]
      type = ADComputeLinearElasticStress
      block = 1
    []
    [psi]
        type = ADDerivativeParsedMaterial
        property_name = psi
        expression = 'g*psie_active+delta*Gc/c0/l*alpha'
        coupled_variables = 'd'
        material_property_names = 'alpha(d) g(d) delta Gc c0 l psie_active'
        derivative_order = 1
    []
    [Gc_delta]
      type = ADParsedMaterial
      property_name = Gc_delta
      expression = 'Gc*delta'
      material_property_names = 'Gc delta'
    []
    [ldl]
      type = LDLNucleationMicroForce
      phase_field = d
      degradation_function = g
      regularization_length = l
      normalization_constant = c0
      tensile_strength = sigma_ts
      hydrostatic_strength = sigma_hs
      fracture_toughness = Gc
      delta = delta
      h_correction = true
      external_driving_force_name = ce
      stress_balance_name = f_nu
      output_properties = 'ce f_nu delta'
      outputs = exodus
    []
    [psie_min]
        type = ADParsedMaterial
        property_name = psie_min
        expression = 'Gc/(2*c0*l)'
        material_property_names = 'Gc c0 l'
        outputs = 'exodus'
    []
    # [hist]
    #     type = HistoryMaximum
    #     prop = psie_active
    #     history_maximum = psie_active_max
    #     minimum = psie_min
    # []
    [ADtoNonAD]
        type = MaterialADConverter
        ad_props_in = 'Gc l c k psie_active_max'
        reg_props_out = 'Gc_reg l_reg c_reg k_reg psie_active_max_reg'
    []
    [mobility]
        type = ParsedMaterial
        property_name = M
        expression = 'c_reg/(2*sqrt(2*Gc_reg*l_reg*psie_active_max_reg))'
        material_property_names = 'c_reg Gc_reg l_reg psie_active_max_reg'
    []
    [damping]
        type = ParsedMaterial
        property_name = M_inv
        expression = 'k_reg/M'
        material_property_names = 'k_reg M'
    []
    [crack_surface_density]
        type = CrackSurfaceDensity
        phase_field = d
        output_properties = gamma
        outputs = exodus
    []
[]

[Postprocessors]
    # [strain_energy]
    #     type = ADElementIntegralMaterialProperty
    #     mat_prop = psie
    #     outputs = csv
    # []
    # [kinetic_energy]
    #     type = KineticEnergy
    #     outputs = csv
    # []
    # [external_work]
    #   type = ExternalWork
    #   boundary = top
    #   forces = 'fx fy'
    #   outputs = csv
    # []
    [max_d]
        type = NodalExtremeValue
        variable = d
        value_type = max
    []
    [max_psie_active]
        type = ADElementExtremeMaterialProperty
        mat_prop = psie_active
        value_type = MAX
        execute_on = 'INITIAL TIMESTEP_END'
    []
    # [J_int_bdry]
    #     type = DynamicBoundaryPhaseFieldJIntegral
    #     density = ${rho}
    #     J_direction = '1 0 0'
    #     strain_energy_density = psie
    #     boundary = 'left right top'
    #     outputs = exodus
    #     # outputs = csv
    # []
    # [J_int_vlm]
    #     type = DynamicVolumePhaseFieldJIntegral
    #     density = ${rho}
    #     J_direction = '1 0 0'
    #     # boundary = 'left right top'
    #     outputs = exodus
    #     # outputs = csv
    # []
    # [Jint_over_Gc]
    #     type = ParsedPostprocessor
    #     pp_names = 'J_int_bdry J_int_vlm'
    #     expression = '(J_int_bdry+J_int_vlm)/${Gc}/0.5'
    #     outputs = csv
    #     # outputs = exodus
    # []
    # [crack_surface_energy]
    #     type = ADElementIntegralMaterialProperty
    #     mat_prop = gamma
    #     outputs = csv
    #     # outputs = exodus
    # []
[]

[Executioner]
    type = Transient
    automatic_scaling = true
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-10
    start_time = 0
    end_time = 1e-4
    dt = 1e-8
    # [TimeIntegrator]
    #     type = PFFExplicitMixedOrder
    #     mass_matrix_tag = mass
    #     damping_matrix_tag = damping
    #     second_order_vars = 'disp_x disp_y d'
    #     first_order_vars = 'd'
    #     phase_field_variables = 'd'
    #     use_constant_mass = true
    #     # use_constant_damping = true
    #     use_constant_damping = false
    # []
[]

[Outputs]
    exodus = true
    print_linear_residuals = false
    file_base = './out_explicit'
    checkpoint = true
    # [csv]
    #     type = CSV
    #     file_base = './out_explicit/l${l}'
    #     execute_vector_postprocessors_on = 'INITIAL TIMESTEP_END'
    # []
[]
