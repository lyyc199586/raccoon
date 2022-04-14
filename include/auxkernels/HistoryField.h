#pragma once

#include "AuxKernel.h"

/**
 *
 */
class HistoryField : public AuxKernel
{
public:
  static InputParameters validParams();

  HistoryField(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const VariableValue & _source_var;
};
