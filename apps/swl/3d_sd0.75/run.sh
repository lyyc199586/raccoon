#!/bin/bash
#SBATCH --job-name Dynamics
#SBATCH -o output.out
#SBATCH -e error.err
#SBATCH -N 4
#SBATCH --ntasks-per-node=128
#SBATCH --mem=200G
#SBATCH -t 48:00:00

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n $SLURM_NPROCS ~/projects/raccoon/raccoon-opt -i fracture-1.i

echo "End: $(date)"