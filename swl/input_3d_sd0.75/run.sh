#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 16 ../../raccoon-opt -i fracture-1.i

echo "End: $(date)"
