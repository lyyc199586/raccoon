#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

# arg1="rz_damage.i p_max=1 SD=0.75"

# mpirun -n 16 ../../raccoon-opt -i $arg1

# mpirun -n 16 ../../raccoon-opt -i acoustic.i
mpirun -n 16 ../../raccoon-opt -i damage.i

echo "End: $(date)"
