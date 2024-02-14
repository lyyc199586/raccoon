# crack from pressurized hole

r = 5

[Mesh]
  [hole]
    type = ParsedCurveGenerator
    x_formula = '${r}*cos(t)'
    y_formula = '${r}*sin(t)'
    section_bounding_t_values = '0.0 ${parse pi} ${fparse 2.0*pi}'
    nums_segments = '10 10'
    constant_names = 'pi'
    constant_expressions = '${parse pi}'
    is_closed_loop = true
  []
[]