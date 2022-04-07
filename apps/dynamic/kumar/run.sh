echo "Start: $(date)"
echo "cwd: $(pwd)"

<<<<<<< HEAD
mpirun -n 8 ~/projects/raccoon/raccoon-opt -i elasticity.i
=======
mpirun -n 12 ~/projects/raccoon/raccoon-opt -i elasticity.i
>>>>>>> add.

echo "End: $(date)"