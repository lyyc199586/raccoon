#pragma once

#include "AuxKernel.h"

/**
 *
 */
class AcousticIntensity : public AuxKernel
{
public:
  static InputParameters validParams();

  AcousticIntensity(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const VariableValue & _pressure;

  const VariableValue & _velocity;
};
