#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks=30
#SBATCH --job-name=kalthoff
#SBATCH --partition=dolbowlab
#SBATCH --mem-per-cpu=10G
#SBATCH -o log.txt

export SLURM_CPU_BIND=none

echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun ../../raccoon-opt -i mechanical.i

echo "End: $(date)"