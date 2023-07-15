#!/bin/sh

#SBATCH -J half-tan
#SBATCH -A CPCF
#SBATCH -p bdwall
#SBATCH -N 2
#SBATCH -t 72:00:00

source ~/.bashrc

# srun -n 72 ../../raccoon-opt -i elasticity.i
srun -n 72 ../../raccoon-opt -i elasticity-tan.i