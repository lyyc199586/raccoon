#!/bin/bash
#SBATCH --job-name SWL3D
#SBATCH -o output.out
#SBATCH -e error.err
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
#SBATCH -N 4
#SBATCH --ntasks-per-node=128
<<<<<<< HEAD
#SBATCH -t 12:00:00
=======
#SBATCH -N 2 
#SBATCH --ntasks-per-node=128
#SBATCH -t 04:00:00
>>>>>>> first run on bridges2
=======
#SBATCH -N 4
#SBATCH --ntasks-per-node=128
#SBATCH -t 12:00:00
>>>>>>> update run.sh
=======
#SBATCH -t 24:00:00
>>>>>>> update
=======
#SBATCH -N 4
#SBATCH --ntasks-per-node=128
#SBATCH -t 24:00:00
>>>>>>> a9d9b251082751d10c24ed460a3b680764a9c360

echo "Start: $(date)"
echo "cwd: $(pwd)"

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
source $HOME/.moose_profile
>>>>>>> first run on bridges2
=======
>>>>>>> update run.sh
=======
>>>>>>> a9d9b251082751d10c24ed460a3b680764a9c360
mpirun -n $SLURM_NPROCS ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"