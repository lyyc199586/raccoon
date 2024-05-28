#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

# arg1="rz_damage.i p_max=1 SD=0.75"

# mpirun -n 16 ../../raccoon-opt -i $arg1

mpirun -n 14 ../../raccoon-opt -i rz_damage.i --color off > log.txt 2>&1 &

echo "End: $(date)"
