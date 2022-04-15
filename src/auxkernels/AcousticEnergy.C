#include "AcousticEnergy.h"
#include "SystemBase.h"

registerMooseObject("raccoonApp", AcousticEnergy);

InputParameters
AcousticEnergy::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params += BaseNameInterface::validParams();
  params.addRequiredCoupledVar("pressure", "pressure");
  params.addRequiredCoupledVar("vel_x", "velocity x");
  params.addRequiredCoupledVar("vel_y", "velocity y");
  params.addParam<MaterialPropertyName>(
      "density", "density", "Name of material property containing density");
      params.addParam<MaterialPropertyName>(
      "wavespeed", "wavespeed", "Name of material property containing wavespeed");
  return params;
}

AcousticEnergy::AcousticEnergy(const InputParameters & parameters)
  : AuxKernel(parameters),
    BaseNameInterface(parameters),
    _rho(getADMaterialProperty<Real>(prependBaseName("density", true))),
    _c(getADMaterialProperty<Real>(prependBaseName("wavespeed", true))),
    _pressure(coupledValue("pressure")),
    _vel_x(coupledValue("vel_x")),
    _vel_y(coupledValue("vel_y"))
{
}

Real
AcousticEnergy::computeValue()
{
  Real v_sq = _vel_x[_qp] * _vel_x[_qp] + _vel_y[_qp] * _vel_y[_qp];
  Real rho = raw_value(_rho[_qp]);
  Real c = raw_value(_c[_qp]);
  return 0.5 * rho * v_sq + 0.5 / (rho * c * c) *_pressure[_qp] * _pressure[_qp];
}