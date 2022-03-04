#!/bin/bash
#SBATCH --job-name Dynamics
#SBATCH -o output.out
#SBATCH -e error.err
<<<<<<< HEAD
<<<<<<< HEAD
#SBATCH -N 4
#SBATCH --ntasks-per-node=128
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

echo "Start: $(date)"
echo "cwd: $(pwd)"

<<<<<<< HEAD
<<<<<<< HEAD
=======
source $HOME/.moose_profile
>>>>>>> first run on bridges2
=======
>>>>>>> update run.sh
mpirun -n $SLURM_NPROCS ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"