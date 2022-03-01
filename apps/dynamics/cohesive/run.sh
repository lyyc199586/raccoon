#!/bin/bash
#SBATCH --job-name Dynamics
#SBATCH -o output.out
#SBATCH -e error.err
#SBATCH -N 2 
#SBATCH --ntasks-per-node=128
#SBATCH -t 04:00:00

echo "Start: $(date)"
echo "cwd: $(pwd)"

source $HOME/.moose_profile
mpirun -n $SLURM_NPROCS ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"