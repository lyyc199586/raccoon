//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#pragma once

#include "SideIntegralPostprocessor.h"
#include "RankTwoTensor.h"
#include "BaseNameInterface.h"

<<<<<<< HEAD
class PhaseFieldJIntegral : public SideIntegralPostprocessor
=======
class PhaseFieldJIntegral : public SideIntegralPostprocessor, public BaseNameInterface
>>>>>>> Revert "Merge branch 'master' into master"
{
public:
  static InputParameters validParams();

  PhaseFieldJIntegral(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;

<<<<<<< HEAD
  /// base name of stress
  const std::string _base_name;
  /// stress tensor
=======
  /// The stress tensor
>>>>>>> Revert "Merge branch 'master' into master"
  const ADMaterialProperty<RankTwoTensor> & _stress;
  /// The strain energy density
  const ADMaterialProperty<Real> & _psie;
  /// Number of displacement variables provided
  const unsigned int _ndisp;
  /// Gradient of displacements
  std::vector<const VariableGradient *> _grad_disp;
  /// Direction of J integral
  const RealVectorValue _t;
};
