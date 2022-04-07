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

  /// history field variable
  MooseVariable & _hist_var;

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  /// The Mesh
  // const MooseMesh & _mesh;

=======
>>>>>>> revert historyfiledbound to serial
=======
=======
>>>>>>> a6304303ba1803fc05b87dedcbd9f93401e67724
  /// serialized solution
  NumericVector<Number> & _serialized_solution;

  /// default = true
<<<<<<< HEAD
>>>>>>> implement parallel
=======
>>>>>>> a6304303ba1803fc05b87dedcbd9f93401e67724
  bool _first;

  /// neighbor nodes map
  std::map<dof_id_type, std::vector<dof_id_type>> _node_to_near_nodes_map;
<<<<<<< HEAD
};
=======
};
>>>>>>> a6304303ba1803fc05b87dedcbd9f93401e67724
