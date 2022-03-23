#include "HistoryFieldBoundsAux.h"
#include "KDTree.h"
#include "MooseMesh.h"
#include "libmesh/node.h"

registerMooseObject("raccoonApp", HistoryFieldBoundsAux);

InputParameters
HistoryFieldBoundsAux::validParams()
{
  InputParameters params = BoundsAuxBase::validParams();
  params.addClassDescription("Provides the upper and lower bound of the phase field fracture "
                             "variable to PETSc's SNES variational inequalities solver.");
  params.addRequiredParam<Real>("fixed_bound_value", "The value of fixed bound for the variable");
  params.addRequiredParam<Real>(
      "threshold_ratio", "The threshold ratio for conditional history bound for the variable");
  params.addRequiredParam<Real>("search_radius",
                                "The search radius for the maximum history field value");
  params.addRequiredParam<NonlinearVariableName>("history_variable", "The history variable");
  // params.addRequiredCoupledVar("history_variable", "The history variable");
  params.set<MooseEnum>("bound_type") = "lower";
  params.suppressParameter<MooseEnum>("bound_type");
  return params;
}

HistoryFieldBoundsAux::HistoryFieldBoundsAux(const InputParameters & parameters)
  : BoundsAuxBase(parameters),
    _fixed_bound_value(getParam<Real>("fixed_bound_value")),
    _threshold_ratio(getParam<Real>("threshold_ratio")),
    _search_radius(getParam<Real>("search_radius")),
    _hist_var_name(parameters.get<NonlinearVariableName>("history_variable")),
    _hist_var(_subproblem.getStandardVariable(_tid, _hist_var_name)),
    _first(true),
    _node_to_near_nodes_map()
{
}

Real
HistoryFieldBoundsAux::getBound()
{
  // build _node_to_near_nodes_map at the first step
  if (_first)
  {
    _first = false;

    // get all points from mesh
    std::vector<Point> all_points;
    std::vector<Node> all_nodes;
    std::vector<dof_id_type> all_nodes_ids;
    for (unsigned int i = 0; i < _mesh.nNodes(); ++i)
    {
      all_nodes.push_back(_mesh.nodeRef(i));
      all_nodes_ids.push_back(i);
      all_points.push_back(_mesh.getMesh().point(i));
    }

    // counstruct kd tree for all points from mesh
    KDTree kd_tree(all_points, _mesh.getMaxLeafSize());

    // loop to find near nodes of every node
    NodeIdRange all_nodes_range(all_nodes_ids.begin(), all_nodes_ids.end(), 1);
    for (const auto & node_id : all_nodes_range)
    {
      Point query_pt = all_nodes[node_id];

      // use radiusSerach to find the number of near nodes
      std::vector<std::pair<std::size_t, Real>> indices_dist;
      kd_tree.radiusSearch(query_pt, _search_radius, indices_dist);

      std::vector<dof_id_type> near_nodes_ids;
      for (unsigned int i = 0; i < indices_dist.size(); ++i)
      {
        near_nodes_ids.push_back(indices_dist[i].first);
      }
      _node_to_near_nodes_map.insert(
          std::pair<dof_id_type, std::vector<dof_id_type>>(node_id, near_nodes_ids));
    }

    // debug: print map
    // for (std::map<dof_id_type, std::vector<dof_id_type>>::const_iterator it =
    //          node_to_near_nodes_map.begin();
    //      it != node_to_near_nodes_map.end();
    //      ++it)
    // {
    //   std::cout << "node id: " << it->first << " neighbor size: " << it->second.size() << std::endl;
    //   for (const auto& elem : it->second) {
    //     std::cout << " " << elem;
    //   }
    //   std::cout << std::endl;
    // }
  }

  // get history field value from near points and find maximum local history field value
  // see NearestNodeValueAux.C
  Real d_max = 0;

  // for debug
  // std::cout << "cur_node_id = " << _current_node->id() << std::endl;

  for (const auto near_node_id : _node_to_near_nodes_map[_current_node->id()])
  {
    const Node & near_node = _mesh.nodeRef(near_node_id);

    // for debug
    // std::cout << "  near_node_id = " << near_node_id << std::endl;

    Real d_hist = _hist_var.getNodalValue(near_node);
    if (d_hist > d_max)
    {
      d_max = d_hist;

      // for debug
      // std::cout << "    update d_max = " << d_max << std::endl;
    }
  }

  // for debug
  // std::cout << "final loacl d_max = " << d_max << std::endl;

  // return lower bound d_old or _fixed_bound_value;
  Real d_old = _var.getNodalValueOld(*_current_node);
  if (d_old >= _threshold_ratio * d_max)
    return d_old;
  else
    return _fixed_bound_value;
}
