#!/bin/bash
#SBATCH --job-name SWL3D
#SBATCH -o output.out
#SBATCH -e error.err
#SBATCH -N 4
#SBATCH --ntasks-per-node=128
#SBATCH -t 24:00:00

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n $SLURM_NPROCS ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"