//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "DynamicPhaseFieldJIntegral.h"

registerMooseObject("raccoonApp", DynamicPhaseFieldJIntegral);

InputParameters
DynamicPhaseFieldJIntegral::validParams()
{
  InputParameters params = SideIntegralPostprocessor::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("Compute the J integral for a phase-field model of fracture");
  params.addRequiredParam<RealVectorValue>("J_direction", "direction of J integral");
  params.addParam<MaterialPropertyName>("strain_energy_density",
                                        "psie"
                                        "Name of the strain energy density");
  params.addRequiredCoupledVar(
      "displacements",
      "The displacements appropriate for the simulation geometry and coordinate system");
  params.addParam<MaterialPropertyName>(
      "density", "density", "Name of material property containing density");
  return params;
}

DynamicPhaseFieldJIntegral::DynamicPhaseFieldJIntegral(const InputParameters & parameters)
  : SideIntegralPostprocessor(parameters),
    BaseNameInterface(parameters),
    _stress(getADMaterialPropertyByName<RankTwoTensor>(prependBaseName("stress"))),
    _psie(getADMaterialProperty<Real>(prependBaseName("strain_energy_density"))),
    _ndisp(coupledComponents("displacements")),
    _grad_disp(coupledGradients("displacements")),
    _t(getParam<RealVectorValue>("J_direction")),
    _rho(getADMaterialProperty<Real>(prependBaseName("density", true))),
    _u_dots(coupledDots("displacements"))
{
  // set unused dimensions to zero
  for (unsigned i = _ndisp; i < 3; ++i)
    _grad_disp.push_back(&_grad_zero);

  for (unsigned int i = _ndisp; i < 3; ++i)
    _u_dots.push_back(&_zero);
}

Real
DynamicPhaseFieldJIntegral::computeQpIntegral()
{
  auto H = RankTwoTensor::initializeFromRows(
      (*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
  RankTwoTensor I2(RankTwoTensor::initIdentity);
  ADRankTwoTensor Sigma = _psie[_qp] * I2 - H.transpose() * _stress[_qp];
  RealVectorValue n = _normals[_qp];
  RealVectorValue u_dot((*_u_dots[0])[_qp], (*_u_dots[1])[_qp], (*_u_dots[2])[_qp]);
  return raw_value(_t * Sigma * n) + 0.5 * raw_value(_rho[_qp]) * u_dot * u_dot;;
}
