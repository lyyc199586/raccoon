//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "PhaseFieldJIntegral.h"

registerMooseObject("raccoonApp", PhaseFieldJIntegral);

InputParameters
PhaseFieldJIntegral::validParams()
{
  InputParameters params = SideIntegralPostprocessor::validParams();
<<<<<<< HEAD
=======
  params += BaseNameInterface::validParams();
>>>>>>> Revert "Merge branch 'master' into master"
  params.addClassDescription("Compute the J integral for a phase-field model of fracture");
  params.addRequiredParam<RealVectorValue>("J_direction", "direction of J integral");
<<<<<<< HEAD
  params.addRequiredParam<MaterialPropertyName>("elastic_energy_name",
                                                "name of the elastic energy");
=======
  params.addParam<MaterialPropertyName>("strain_energy_density",
                                        "psie"
                                        "Name of the strain energy density");
>>>>>>> Revert "Merge branch 'master' into master"
  params.addRequiredCoupledVar(
      "displacements",
      "The displacements appropriate for the simulation geometry and coordinate system");
  return params;
}

PhaseFieldJIntegral::PhaseFieldJIntegral(const InputParameters & parameters)
  : SideIntegralPostprocessor(parameters),
<<<<<<< HEAD
    _base_name(isParamValid("base_name") ? getParam<std::string>("base_name") + "_" : ""),
    _stress(getADMaterialPropertyByName<RankTwoTensor>(_base_name + "pk1_stress")),
    _E_elastic(getADMaterialProperty<Real>("elastic_energy_name")),
=======
    BaseNameInterface(parameters),
    _stress(getADMaterialPropertyByName<RankTwoTensor>(prependBaseName("stress"))),
    _psie(getADMaterialProperty<Real>(prependBaseName("strain_energy_density"))),
>>>>>>> Revert "Merge branch 'master' into master"
    _ndisp(coupledComponents("displacements")),
    _grad_disp(coupledGradients("displacements")),
    _t(getParam<RealVectorValue>("J_direction"))
{
<<<<<<< HEAD
=======
  // set unused dimensions to zero
  for (unsigned i = _ndisp; i < 3; ++i)
    _grad_disp.push_back(&_grad_zero);
>>>>>>> Revert "Merge branch 'master' into master"
}

Real
PhaseFieldJIntegral::computeQpIntegral()
{
<<<<<<< HEAD
  RankTwoTensor H(_grad_disp_0[_qp], _grad_disp_1[_qp], _grad_disp_2[_qp]);
=======
  RankTwoTensor H((*_grad_disp[0])[_qp], (*_grad_disp[1])[_qp], (*_grad_disp[2])[_qp]);
>>>>>>> Revert "Merge branch 'master' into master"
  RankTwoTensor I2(RankTwoTensor::initIdentity);
  ADRankTwoTensor Sigma = _psie[_qp] * I2 - H.transpose() * _stress[_qp];
  RealVectorValue n = _normals[_qp];
<<<<<<< HEAD
  ADReal value = _t * Sigma * n;
  return value.value();
=======
  return raw_value(_t * Sigma * n);
>>>>>>> Revert "Merge branch 'master' into master"
}
