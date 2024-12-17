#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --job-name=RVE
#SBATCH --partition=parallel
#SBATCH --time=24:00:00
#SBATCH -A sghosh20
#SBATCH --mail-user=yliu664@jh.edu
#SBATCH --mail-type=ALL
#SBATCH -o rve_%j.out

echo "Start: $(date)"
echo "cwd: $(pwd)"

module purge
module load gcc/9.3.0 python/3.9.0 cmake/3.24.2 openmpi/3.1.6
set -x
export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77
export MOOSE_JOBS=48 METHODS=opt

mpiexec ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"