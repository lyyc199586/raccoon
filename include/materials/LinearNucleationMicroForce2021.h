//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#pragma once

#include "Material.h"
#include "BaseNameInterface.h"
#include "DerivativeMaterialPropertyNameInterface.h"

<<<<<<< HEAD:include/materials/LinearNucleationMicroForce2021.h
/**
 * The class implements the external driving force to recover a Drucker-Prager
 * strength envelope. See Kumar et. al. https://doi.org/10.1016/j.jmps.2020.104027.
 */
class LinearNucleationMicroForce2021 : public Material,
                                       public BaseNameInterface,
                                       public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  LinearNucleationMicroForce2021(const InputParameters & parameters);
=======
class NucleationMicroForceBase : public Material,
                                 public BaseNameInterface,
                                 public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();
  NucleationMicroForceBase(const InputParameters & parameters);
>>>>>>> devel:include/materials/nucleation_models/NucleationMicroForceBase.h

protected:
  ///@{ fracture properties
  /// The fracture toughness
  const ADMaterialProperty<Real> & _Gc;
  /// The normalization constant
  const ADMaterialProperty<Real> & _c0;
  /// phase field regularization length
  const ADMaterialProperty<Real> & _L;
  ///@}

  /// Lame's first parameter
  const ADMaterialProperty<Real> & _lambda;
  /// The shear modulus
  const ADMaterialProperty<Real> & _mu;

<<<<<<< HEAD:include/materials/LinearNucleationMicroForce2021.h
  /// The critical tensile strength
  const Real & _sigma_ts;

  /// The critical compressive strength
  const Real & _sigma_cs;

  /// The regularization length dependent parameter
  const Real & _delta;

=======
>>>>>>> devel:include/materials/nucleation_models/NucleationMicroForceBase.h
  /// The stress tensor
  const ADMaterialProperty<RankTwoTensor> & _stress;
  /// Name of the stress space balance
  const MaterialPropertyName _stress_balance_name;
  /// stress space balance
  ADMaterialProperty<Real> & _stress_balance;

<<<<<<< HEAD:include/materials/LinearNucleationMicroForce2021.h
  /// Name of the phase-field variable
  const VariableName _d_name;
  // @{ The degradation function and its derivative w/r/t damage
  const MaterialPropertyName _g_name;
  const ADMaterialProperty<Real> & _g;
  const ADMaterialProperty<Real> & _dg_dd;
  // @}
  const bool _if_stress_intact;
=======
  /// Name of the external driving force
  const MaterialPropertyName _ex_driving_name;
  /// The external nucleation driving force
  ADMaterialProperty<Real> & _ex_driving;

  /// @{ The degradation function and its derivative w/r/t damage
  const VariableName _d_name;
  const MaterialPropertyName _g_name;
  const ADMaterialProperty<Real> & _g;
  const ADMaterialProperty<Real> & _dg_dd;
  /// @}
>>>>>>> devel:include/materials/nucleation_models/NucleationMicroForceBase.h
};
