#pragma once

#include "Kernel.h"
// #include "NSPressureDerivs.h"

// ForwardDeclarations

class PressureGradient : public Kernel
{
public:
  static InputParameters validParams();

  PressureGradient(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
//   virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  // Parameters
  const unsigned int _component;
  
  const VariableValue & _pressure;

  // Coupled gradients
  // const VariableGradient & _grad_p;

};