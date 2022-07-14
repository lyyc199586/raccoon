#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 16 ../../raccoon-opt -i pressure_test.i

echo "End: $(date)"
