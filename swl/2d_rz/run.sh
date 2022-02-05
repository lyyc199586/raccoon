#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 16 ../../raccoon-opt -i rz_damage.i

echo "End: $(date)"
