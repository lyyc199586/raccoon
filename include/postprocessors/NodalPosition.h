#pragma once

#include "GeneralPostprocessor.h"

class MooseMesh;

namespace libMesh
{
class Node;
}

/**
 * Sums a nodal value across all processors and multiplies the result
 * by a scale factor.
 */
class NodalPosition : public GeneralPostprocessor
{
public:
  static InputParameters validParams();

  NodalPosition(const InputParameters & parameters);

  virtual void initialize() override {}
  virtual void execute() override;
  virtual Real getValue() const override;
  void initialSetup() override;

protected:
  MooseMesh & _mesh;
  Node * _node_ptr;
  Point _node_location;
  Real _position; // x, y, or z coord of position
};
