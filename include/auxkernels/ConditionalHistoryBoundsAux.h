#pragma once

#include "MooseTypes.h"
#include "BoundsAuxBase.h"

/**
 *
 */
class ConditionalHistoryBoundsAux : public BoundsAuxBase
{
public:
  static InputParameters validParams();

  ConditionalHistoryBoundsAux(const InputParameters & parameters);

protected:
  virtual Real getBound() override;

  /// The value of the fixed bound for the variable
  Real _fixed_bound_value;

  /// The threshold for conditional bound for the variable
  Real _threshold_value;

  /// The search radius for the maximum history field value
  Real _search_radius;

  /// history field variable
  MooseVariable & _hist_var;

  /// serialized solution
  NumericVector<Number> & _serialized_solution;

  /// default = true
  bool _first;

  /// neighbor nodes map
  std::map<dof_id_type, std::vector<dof_id_type>> _node_to_near_nodes_map;
};
