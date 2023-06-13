#include "NodalPosition.h"

// MOOSE includes
#include "MooseMesh.h"
#include "MooseVariable.h"
#include "SubProblem.h"

#include "libmesh/node.h"

registerMooseObject("MooseApp", NodalPosition);

InputParameters
NodalPosition::validParams()
{
  InputParameters params = GeneralPostprocessor::validParams();
  params.addRequiredParam<unsigned int>("nodeid", "The node ");
  params.addRequiredParam<std::string>("coord", "The coordinate to output (x, y, or z).");
  params.addClassDescription("Outputs position of a node with node id");
  return params;
}

NodalPosition::NodalPosition(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _mesh(_subproblem.mesh()),
    _node_ptr(nullptr),
    _node_location(Point(0, 0, 0)),
    _position(0)
{
  // This class may be too dangerous to use if renumbering is enabled,
  // as the nodeid parameter obviously depends on a particular
  // numbering.
  // if (_mesh.getMesh().allow_renumbering())
  //   mooseError("NodalPosition should only be used when node renumbering is disabled.");
}

void
NodalPosition::initialSetup()
{
  _node_ptr = _mesh.getMesh().query_node_ptr(getParam<unsigned int>("nodeid"));
  bool found_node_ptr = _node_ptr;
  _communicator.max(found_node_ptr);

  if (!found_node_ptr)
    mooseError("Node #",
               getParam<unsigned int>("nodeid"),
               " specified in '",
               name(),
               "' not found in the mesh!");
}

void
NodalPosition::execute()
{
  std::string coord = getParam<std::string>("coord");
  if (_node_ptr && _node_ptr->processor_id() == processor_id())
    // _value = _subproblem.getStandardVariable(_tid, _var_name).getNodalValue(*_node_ptr);
    _node_location = (*_node_ptr)(0);
    if (coord == "x") {
      _position = _node_location(0);
    } else if (coord == "y") {
      _position = _node_location(1);
    } else if (coord == "z") {
      _position = _node_location(2);
    } else {
      mooseError("Invalid coordinates: ", coord);
    }
}

Real
NodalPosition::getValue()
{
  return _position;
}
