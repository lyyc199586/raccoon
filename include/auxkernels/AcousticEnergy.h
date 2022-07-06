#pragma once

#include "AuxKernel.h"
#include "BaseNameInterface.h"

/**
 *
 */
class AcousticEnergy : public AuxKernel, public BaseNameInterface
{
public:
  static InputParameters validParams();

  AcousticEnergy(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  /// The density
  const ADMaterialProperty<Real> & _rho;

  /// The wavespeed
  const ADMaterialProperty<Real> & _c;

  /// The pressures
  const VariableValue & _pressure;

  /// The velocities
  const VariableValue & _vel_x;
  const VariableValue & _vel_y;
};
