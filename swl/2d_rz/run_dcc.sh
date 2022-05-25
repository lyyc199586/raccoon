#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks=35
#SBATCH --job-name=SWL-RZ
#SBATCH --partition=dolbowlab
#SBATCH --mem-per-cpu=20G
#SBATCH -o output.out

export SLURM_CPU_BIND=none

memba activate moose

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun ../../raccoon-opt -i rz_damage.i

echo "End: $(date)