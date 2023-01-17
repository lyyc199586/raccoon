//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#include "ComputeFatigueDegradationFunction.h"
#include <cmath>

registerMooseObject("raccoonApp", ComputeFatigueDegradationFunction);

InputParameters
ComputeFatigueDegradationFunction::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("computes fatigue degradation function");
  params.addParam<MaterialPropertyName>("elastic_energy_mat",
                                        "name of the material that holds the elastic energy");
  params.addCoupledVar("elastic_energy_var",
                       "name of the elastic energy variable defined as aux variable");
  params.addParam<MaterialPropertyName>(
      "alpha_bar_name",
      "alpha_bar",
      "name of the parameter used in fatigue degradation function equation");
  params.addParam<MaterialPropertyName>(
      "f_alpha_name", "f_alpha", "name of the fatigue degradation function");
  params.addParam<MaterialPropertyName>(
      "f_alpha_type",
      "f_alpha_type",
      "type of the fatigue degradation function (logarithmic or asymptotic");
  params.addParam<Real>("kappa", 0, "parameter in logaritmic fatigue degaradtion function");
  params.addRequiredParam<Real>("alpha_T", "fatigue threshold");
  params.addCoupledVar("initial_alpha_bar", "initial value for alpha_bar");
  params.addParam<MaterialPropertyName>(
      "degradation_mat", "g", "name of the material that holds the degradation");

  return params;
}

ComputeFatigueDegradationFunction::ComputeFatigueDegradationFunction(const InputParameters & parameters)
  : ADMaterial(parameters),
    _E_el_name(isParamValid("elastic_energy_mat")
                   ? getParam<MaterialPropertyName>("elastic_energy_mat")
                   : ""),
    _E_el_active(isParamValid("elastic_energy_mat")
                     ? &getADMaterialProperty<Real>(_E_el_name + "_active")
                     : nullptr),
    _E_el_active_old(isParamValid("elastic_energy_mat")
                         ? &getMaterialPropertyOld<Real>(_E_el_name + "_active")
                         : nullptr),
    _E_el_active_var(isParamValid("elastic_energy_var") ? &coupledValue("elastic_energy_var")
                                                        : nullptr),
    _E_el_active_var_old(isParamValid("elastic_energy_var") ? &coupledValueOld("elastic_energy_var")
                                                            : nullptr),
    _alpha_bar(declareADProperty<Real>(getParam<MaterialPropertyName>("alpha_bar_name"))),
    _alpha_bar_old(getMaterialPropertyOld<Real>("alpha_bar_name")),
    _f_alpha(declareADProperty<Real>(getParam<MaterialPropertyName>("f_alpha_name"))),
    _f_alpha_type(getParam<MaterialPropertyName>("f_alpha_type")),
    _kappa(getParam<Real>("kappa")),
    _alpha_T(getParam<Real>("alpha_T")),
    _alpha_bar_init(isParamValid("initial_alpha_bar") ? &coupledValue("initial_alpha_bar")
                                                      : nullptr),
    // _g(getADMaterialProperty<Real>("degradation_mat")),
    // _g_old(getMaterialPropertyOld<Real>("degradation_mat")),
    _fatigue_flag(declareProperty<bool>("fatigue_flag"))
{
}

void
ComputeFatigueDegradationFunction::initQpStatefulProperties()
{
  _alpha_bar[_qp] = _alpha_bar_init ? (*_alpha_bar_init)[_qp] : 0.0;
  _fatigue_flag[_qp] = false;
}

void
ComputeFatigueDegradationFunction::computeQpProperties()
{
  ADReal E_el_active = _E_el_active ? (*_E_el_active)[_qp] : (*_E_el_active_var)[_qp];
  ADReal E_el_active_old =
      _E_el_active_old ? (*_E_el_active_old)[_qp] : (*_E_el_active_var_old)[_qp];

  // calculate degraded active elastic energy
  // ADReal alpha = _g[_qp] * E_el_active;
  // ADReal alpha_old = _g_old[_qp] * E_el_active_old;

  // yc: change it to ungraded active elastic energy for now
  ADReal alpha = E_el_active;
  ADReal alpha_old = E_el_active_old;

  // update alpha_bar
  if (_fatigue_flag[_qp] == false)
  {
    _alpha_bar[_qp] = _alpha_bar_old[_qp] + (alpha - alpha_old);
  }
  else
  {
    if (alpha > alpha_old)
      _alpha_bar[_qp] = _alpha_bar_old[_qp] + (alpha - alpha_old);
    else
      _alpha_bar[_qp] = _alpha_bar_old[_qp];
  }

  if (_alpha_bar[_qp] > _alpha_T)
    _fatigue_flag[_qp] = true;

  // calculate f_alpha
  // asymptotic
  if (_f_alpha_type == "asymptotic")
  {

    if (_alpha_bar[_qp] < _alpha_T)
      _f_alpha[_qp] = 1.0;
    else
      _f_alpha[_qp] = std::pow(2 * _alpha_T / (_alpha_T + _alpha_bar[_qp]), 2.0);

  // logarithmic
  }
  else if (_f_alpha_type == "logarithmic")
  {

    if (_alpha_bar[_qp] < _alpha_T)
      _f_alpha[_qp] = 1.0;
    else if ((_alpha_bar[_qp] > _alpha_T) &&
             (_alpha_bar[_qp] < _alpha_T * std::pow(10.0, 1.0 / _kappa)))
      _f_alpha[_qp] = std::pow(1 - _kappa * std::log10(_alpha_bar[_qp] / _alpha_T), 2.0);
    else
      _f_alpha[_qp] = 0.0;
  }
  else
    mooseError("Invalid type of fatigue degaradtion fucntion");
}
