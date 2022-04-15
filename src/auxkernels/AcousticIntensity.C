#include "AcousticIntensity.h"
#include "SystemBase.h"

registerMooseObject("raccoonApp", AcousticIntensity);

InputParameters
AcousticIntensity::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addRequiredCoupledVar("pressure", "pressure");
  params.addRequiredCoupledVar("velocity", "velocity component");
  return params;
}

AcousticIntensity::AcousticIntensity(const InputParameters & parameters)
  : AuxKernel(parameters),
    _pressure(coupledValue("pressure")),
    _velocity(coupledValue("velocity"))
{
}

Real
AcousticIntensity::computeValue()
{
  return _pressure[0]*_velocity[0];
}