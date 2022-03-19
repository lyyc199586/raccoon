#pragma once

#include "AuxKernel.h"

/**
 *
 */
class HistoryField : public AuxKernel
{
public:
  HistoryField(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const VariableValue & _source_var;

public:
  static InputParameters validParams();
};
