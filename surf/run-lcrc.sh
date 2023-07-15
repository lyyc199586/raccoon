#!/bin/sh

#SBATCH -J surf
#SBATCH -p bdwall
#SBATCH -N 1
#SBATCH -t 4:00:00

source ~/.bashrc

srun -n 36 ../raccoon-opt -i elasticity.i