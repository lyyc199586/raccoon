#pragma once

#include "Material.h"
#include "BaseNameInterface.h"

/**
 * The class implements the external driving force to recover a Drucker-Prager
 * strength envelope. See Kumar et. al. https://doi.org/10.1016/j.jmps.2020.104027.
 */
class ComputeStrengthSurface : public Material, public BaseNameInterface
{
public:
  static InputParameters validParams();

  ComputeStrengthSurface(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Name of f(sigma)
  const MaterialPropertyName _f_sigma_name;

  /// f(sigma)
  ADMaterialProperty<Real> & _f_sigma;

  /// The critical tensile strength
  const Real & _sigma_ts;

  /// The critical compressive strength
  const Real & _sigma_cs;

  /// The stress tensor
  const ADMaterialProperty<RankTwoTensor> & _stress;
};