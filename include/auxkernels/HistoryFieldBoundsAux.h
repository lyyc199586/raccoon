#pragma once

#include "MooseTypes.h"
#include "BoundsAuxBase.h"

/**
 *
 */
class HistoryFieldBoundsAux : public BoundsAuxBase
{
public:
  static InputParameters validParams();

  HistoryFieldBoundsAux(const InputParameters & parameters);

protected:
  virtual Real getBound() override;

  /// The value of the fixed bound for the variable
  Real _fixed_bound_value;

  /// The threshold for conditional bound for the variable
  Real _threshold_ratio;

  /// The search radius for the maximum history field value
  Real _search_radius;

  /// Name of history field variable
  NonlinearVariableName _hist_var_name;

  /// history field variable
  MooseVariable & _hist_var;

<<<<<<< HEAD
  /// The Mesh
  // const MooseMesh & _mesh;

=======
>>>>>>> revert historyfiledbound to serial
  bool _first;

  // neighbor nodes map
  std::map<dof_id_type, std::vector<dof_id_type>> _node_to_near_nodes_map;
};