#pragma once

#include "ElementIntegralPostprocessor.h"
#include "RankTwoTensor.h"
#include "BaseNameInterface.h"

class DJint : public ElementIntegralPostprocessor, public BaseNameInterface
{
public:
  static InputParameters validParams();

  DJint(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;

private:
  
  const RealVectorValue _t;
  const ADMaterialProperty<Real> & _rho;
  const unsigned int _ndisp;
  std::vector<const VariableValue *> _vel; // dot(u)
  std::vector<const VariableValue *> _accel; // ddot(u)
  std::vector<const VariableGradient *> _grad_u;
  std::vector<const VariableGradient *> _grad_u_dots;
};
