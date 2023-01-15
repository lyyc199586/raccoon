#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 16 ../raccoon-opt -i elastic.i

echo "End: $(date)"
