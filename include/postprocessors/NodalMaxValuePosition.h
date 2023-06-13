
#pragma once

#include "NodalVariablePostprocessor.h"

class MooseMesh;

namespace libMesh
{
class Node;
}

/**
 * Computes the position of the node with the maximum value across all processes
 */
class NodalMaxValuePosition : public NodalVariablePostprocessor
{
public:
  static InputParameters validParams();

  NodalMaxValuePosition(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual Real getValue() override;
  virtual void finalize() override;

  /**
   * The method called to compute the value that will be returned
   * by the proxy value.
   */
  virtual Real computeValue();

  void threadJoin(const UserObject & y) override;

protected:
  Real _value;
  dof_id_type _node_id;
  Real _position; // x, y or z coord of position
};
