#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"


mpirun -n 16 ../../raccoon-opt -i solid.i

echo "End: $(date)"
