#include "NodalMaxValuePosition.h"
#include "MooseMesh.h"
#include "SubProblem.h"
// libMesh
#include "libmesh/node.h"
#include "libmesh/boundary_info.h"

registerMooseObject("MooseApp", NodalMaxValuePosition);

InputParameters
NodalMaxValuePosition::validParams()
{
  InputParameters params = NodalVariablePostprocessor::validParams();
  params.addClassDescription(
      "Finds the node position with the maximum nodal value across all postprocessors.");
  params.addRequiredParam<std::string>("coord", "The coordinate to output (x, y, or z).");
  return params;
}

NodalMaxValuePosition::NodalMaxValuePosition(const InputParameters & parameters)
  : NodalVariablePostprocessor(parameters), _value(-std::numeric_limits<Real>::max()), _position(0)
{
}

void
NodalMaxValuePosition::initialize()
{
  _value = -std::numeric_limits<Real>::max();
}

Real
NodalMaxValuePosition::computeValue()
{
  return _u[_qp];
}

void
NodalMaxValuePosition::execute()
{
  Real val = computeValue();

  if (val > _value)
  {
    _value = val;
    _node_id = _current_node->id();
  }
}

Real
NodalMaxValuePosition::getValue()
{
  Node * node_ptr = _mesh.getMesh().query_node_ptr(_node_id);
  Point node_location = (*node_ptr)(0);
  std::string coord = getParam<std::string>("coord");

  if (coord == "x")
  {
    _position = node_location(0);
  }
  else if (coord == "y")
  {
    _position = node_location(1);
  }
  else if (coord == "z")
  {
    _position = node_location(2);
  }
  else
  {
    mooseError("Invalid coordinates: ", coord);
  }
  return _position;
}
void
NodalMaxValuePosition::finalize()
{
  gatherProxyValueMax(_value, _node_id);
}

void
NodalMaxValuePosition::threadJoin(const UserObject & y)
{
  const NodalMaxValuePosition & pps = static_cast<const NodalMaxValuePosition &>(y);
  if (pps._value > _value)
  {
    _value = pps._value;
    _node_id = pps._node_id;
    _position = pps._position;
  }
}
