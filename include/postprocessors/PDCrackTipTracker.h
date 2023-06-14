
#pragma once

#include "NodalVariablePostprocessor.h"

class MooseMesh;

namespace libMesh
{
class Node;
}

/**
 * Computes the position of the node with the maximum distance across all processes
 */
class PDCrackTipTracker : public NodalVariablePostprocessor
{
public:
  static InputParameters validParams();

  PDCrackTipTracker(const InputParameters & parameters);

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
  const unsigned int _component;
  Real _dist;
  dof_id_type _node_id;
  Real _position;
};
