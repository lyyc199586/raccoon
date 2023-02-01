#include "ComputeStrengthSurface.h"

registerADMooseObject("raccoonApp", ComputeStrengthSurface);

InputParameters
ComputeStrengthSurface::validParams()
{
  InputParameters params = Material::validParams();
  params += BaseNameInterface::validParams();

  params.addClassDescription(
      "This class computes the strength surface of various types.");
  params.addRequiredParam<Real>(
      "tensile_strength", "The tensile strength of the material beyond which the material fails.");
  params.addRequiredParam<Real>(
      "compressive_strength",
      "The compressive strength of the material beyond which the material fails.");
  params.addParam<MaterialPropertyName>(
      "f_sigma_name",
      "f_sigma",
      "Name of the material that compute f(sigma)");
  return params;
}

ComputeStrengthSurface::ComputeStrengthSurface(const InputParameters & parameters)
  : Material(parameters),
    BaseNameInterface(parameters),
    _f_sigma(declareADProperty<Real>(prependBaseName("f_sigma_name", true))),
    _sigma_ts(getParam<Real>("tensile_strength")),
    _sigma_cs(getParam<Real>("compressive_strength")),
    _stress(getADMaterialProperty<RankTwoTensor>(prependBaseName("stress")))
{
}

void
ComputeStrengthSurface::computeQpProperties()
{
  // Invariants of the stress
  ADReal I1 = _stress[_qp].trace();
  ADRankTwoTensor stress_dev = _stress[_qp].deviatoric();
  ADReal J2 = 0.5 * stress_dev.doubleContraction(stress_dev);

  // Just to be extra careful... J2 is for sure non-negative.
  mooseAssert(J2 >= 0, "Negative J2");

  // define zero J2's derivative
  if (MooseUtils::absoluteFuzzyEqual(J2, 0))
    J2.value() = libMesh::TOLERANCE * libMesh::TOLERANCE;

  // compute f(stress) (no phase field case)
  _f_sigma[_qp] = sqrt(J2) + (_sigma_cs-_sigma_ts)/sqrt(3)/(_sigma_cs+_sigma_ts) * I1 - 2*_sigma_cs*_sigma_ts/sqrt(3)/(_sigma_cs+_sigma_ts);
}