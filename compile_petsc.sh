#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --job-name=compile_petsc
#SBATCH --partition=RM-shared
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=2000M
#SBATCH --mail-user=yl740@duke.edu
#SBATCH --mail-type=ALL
#SBATCH -o compile_petsc_%j.out

echo "Start: $(date)"
echo "cwd: $(pwd)"

module purge
module load anaconda3/2022.10  mvapich2/2.3.5-gcc8.3.1
set -x
export CC=mpicc CXX=mpicxx FC=mpif90 F90=mpif90 F77=mpif77

## install petsc
cd ./moose/scripts
export MOOSE_JOBS=8 METHODS=opt
./update_and_rebuild_petsc.sh \
--download-cmake

## test after compile
cd ../petsc/
make PETSC_DIR=/ocean/projects/mch230012p/yliup/projects/raccoon/moose/petsc PETSC_ARCH=arch-moose check
echo "End: $(date)"