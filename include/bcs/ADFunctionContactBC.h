#pragma once

#include "ADIntegratedBC.h"
#include "Function.h"

class ADFunctionContactBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  ADFunctionContactBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  const Function & _func;
  const Function & _pfunc;
};