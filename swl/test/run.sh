#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 16 ../../raccoon-opt -i rz_test_2drz.i

echo "End: $(date)"
