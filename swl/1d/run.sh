#!/bin/bash

echo "Start: $(date)"
echo "cwd: $(pwd)"


nohup mpirun -n 14 ../../raccoon-opt -i solid.i > log.txt 2>&1 &

echo "End: $(date)"
