#include "ADFunctionContactBC.h"

registerMooseObject("raccoonApp", ADFunctionContactBC);

InputParameters
ADFunctionContactBC::validParams()
{
   InputParameters params = ADIntegratedBC::validParams();
  params.addClassDescription(
      "Enforces a (possibly) time and space-dependent MOOSE Function Dirichlet boundary condition "
      "on a time and space-dependent boundary in a weak sense by penalizing differences between the current "
      "solution and the Dirichlet data.");
  params.addRequiredParam<FunctionName>("penalty_function", "Penalty function that controls the contact boundary");
  params.addRequiredParam<FunctionName>("function", "Forcing function that controls the value to enforce");

  return params;
}

ADFunctionContactBC::ADFunctionContactBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), _func(getFunction("function")), _pfunc(getFunction("penalty_function"))
{
}

ADReal
ADFunctionContactBC::computeQpResidual()
{
  return  _pfunc.value(_t, _q_point[_qp]) * _test[_i][_qp] * (-_func.value(_t, _q_point[_qp]) + _u[_qp]);
}