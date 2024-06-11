#include "DJint.h"

registerMooseObject("raccoonApp", DJint);

InputParameters
DJint::validParams()
{
  InputParameters params = ElementIntegralPostprocessor::validParams();
  params += BaseNameInterface::validParams();
  params.addClassDescription("Second part of the dynamic J intgral");
  params.addRequiredParam<RealVectorValue>("J_direction", "direction of J integral");
  params.addRequiredCoupledVar(
      "displacements",
      "The displacement variables appropriate for the simulation geometry and coordinate system");
  params.addRequiredCoupledVar(
      "velocities",
      "The velocity variables appropriate for the simulation geometry and coordinate system");
  params.addParam<MaterialPropertyName>(
      "density",
      "density",
      "Name of Material Property  or a constant real number defining the density of the beam.");
  params.addRequiredParam<RealVectorValue>("J_direction", "Direction of J integral");
  return params;
}

DJint::DJint(const InputParameters & parameters)
  : ElementIntegralPostprocessor(parameters),
    BaseNameInterface(parameters),
    _t(getParam<RealVectorValue>("J_direction")),
    _rho(getADMaterialProperty<Real>(prependBaseName("density", true))),
    _ndisp(coupledComponents("displacements")),
    _vel(coupledDots("displacements")),
    _accel(coupledDots("velocities")),
    _grad_u(coupledGradients("displacements")),
    _grad_u_dots(coupledGradients("velocities"))
{
  // assign zeros
  for (unsigned int i = _ndisp; i < 3; ++i) {
    _vel.push_back(&_zero);
    _accel.push_back(&_zero);
    _grad_u.push_back(&_grad_zero);
    _grad_u_dots.push_back(&_grad_zero);
  }
}

Real
DJint::computeQpIntegral()
{
  // ddot(u), dot(u), grad(u), grad(u_dot)
  RealVectorValue u_dot((*_vel[0])[_qp], (*_vel[1])[_qp], (*_vel[2])[_qp]);
  RealVectorValue u_dotdot((*_accel[0])[_qp], (*_accel[1])[_qp], (*_accel[2])[_qp]);

  auto grad_u =
      RankTwoTensor::initializeFromRows((*_grad_u[0])[_qp], (*_grad_u[1])[_qp], (*_grad_u[2])[_qp]);
  auto grad_u_dot =
      RankTwoTensor::initializeFromRows((*_grad_u_dots[0])[_qp], (*_grad_u_dots[1])[_qp], (*_grad_u_dots[2])[_qp]);

  RealVectorValue vec = grad_u.transpose() * u_dotdot  - grad_u_dot.transpose() * u_dot;
  
  return MetaPhysicL::raw_value(_rho[_qp] * _t * vec);
}