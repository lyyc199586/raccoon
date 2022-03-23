#include "HistoryField.h"
#include "SystemBase.h"

registerMooseObject("raccoonApp", HistoryField);

InputParameters
HistoryField::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addRequiredCoupledVar("source_variable", "Source variable to be watched");
  return params;
}

HistoryField::HistoryField(const InputParameters & parameters)
  : AuxKernel(parameters),
    _source_var(coupledValue("source_variable"))
{
}

Real
HistoryField::computeValue()
{
  Real d_max = _var.nodalValueOldArray()[0];
  Real d = _source_var[0];
  if (d > d_max)
    return d;
  else 
    return d_max;
}