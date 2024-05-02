#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --job-name=compile_libmesh
#SBATCH --partition=RM-shared
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --mail-user=yl740@duke.edu
#SBATCH --mail-type=ALL
#SBATCH -o compile_libmesh_%j.out

echo "Start: $(date)"
echo "cwd: $(pwd)"

module purge
module load anaconda3/2022.10 mvapich2/2.3.5-gcc8.3.1
set -x
export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77

cd ./moose/scripts
export MOOSE_JOBS=8 METHODS=opt
# ./update_and_rebuild_petsc.sh \
# --download-cmake
./update_and_rebuild_libmesh.sh \
# --with-boost 

echo "End: $(date)"