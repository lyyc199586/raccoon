#include "PressureGradient.h"
// #include "NS.h"

registerMooseObject("raccoonApp", PressureGradient);

InputParameters
PressureGradient::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addRequiredCoupledVar("pressure", "pressure p(x, t)");
  params.addRequiredParam<unsigned int>("component", "number of component (0 = x, 1 = y, 2 = z)");
  params.addClassDescription(
      "Implements the pressure gradient term for one of the Navier Stokes momentum equations.");

  return params;
}

PressureGradient::PressureGradient(const InputParameters & parameters)
  : Kernel(parameters),
    _component(getParam<unsigned int>("component")),
    _pressure(coupledValue("pressure"))
{
}

Real
PressureGradient::computeQpResidual()
{
  return -_pressure[_qp] * _grad_test[_i][_qp](_component);
}

Real
PressureGradient::computeQpJacobian()
{
  return 0.;
}