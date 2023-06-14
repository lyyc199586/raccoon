#include "PDCrackTipTracker.h"
#include "MooseMesh.h"
#include "SubProblem.h"
// libMesh
#include "libmesh/node.h"
#include "libmesh/boundary_info.h"

registerMooseObject("MooseApp", PDCrackTipTracker);

InputParameters
PDCrackTipTracker::validParams()
{
  InputParameters params = NodalVariablePostprocessor::validParams();
  params.addClassDescription(
      "Finds the node position with the maximum distance of $d>d_cr$ to initial crack tip. Use "
      "this postprocessor with an evaluated distance field.");
  params.addRequiredParam<Real>("initial_coord",
                                "The coordinate of the initial crack tip (x, y or z coordinate)");
  params.addRequiredParam<unsigned int>("component", "The coordinate componet to track");
  return params;
}

PDCrackTipTracker::PDCrackTipTracker(const InputParameters & parameters)
  : NodalVariablePostprocessor(parameters),
    _component(getParam<unsigned int>("component")),
    _dist(-std::numeric_limits<Real>::max()),
    _position(getParam<Real>("initial_coord"))
{
}

void
PDCrackTipTracker::initialize()
{
  _dist = -std::numeric_limits<Real>::max();
}

Real
PDCrackTipTracker::computeValue()
{
  return _u[_qp];
}

void
PDCrackTipTracker::execute()
{
  Real dist = computeValue();

  if (dist > _dist)
  {
    _dist = dist;
    _node_id = _current_node->id();
  }
}

Real
PDCrackTipTracker::getValue()
{
  Node * node_ptr = _mesh.getMesh().query_node_ptr(_node_id);
  
  // update crack tip positive if max distance is positive
  if (_dist > 0)
    _position = (*node_ptr)(_component);
  return _position;
}

void
PDCrackTipTracker::finalize()
{
  gatherProxyValueMax(_dist, _node_id);
}

void
PDCrackTipTracker::threadJoin(const UserObject & y)
{
  const PDCrackTipTracker & pps = static_cast<const PDCrackTipTracker &>(y);
  if (pps._dist > _dist)
  {
    _dist = pps._dist;
    _node_id = pps._node_id;
    _position = pps._position;
  }
}
