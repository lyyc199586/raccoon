echo "Start: $(date)"
echo "cwd: $(pwd)"

<<<<<<< HEAD
<<<<<<< HEAD
mpirun -n 8 ~/projects/raccoon/raccoon-opt -i elasticity.i
=======
mpirun -n 12 ~/projects/raccoon/raccoon-opt -i elasticity.i
>>>>>>> add.
=======
mpirun -n 12 ~/projects/raccoon/raccoon-opt -i elasticity.i
>>>>>>> a6304303ba1803fc05b87dedcbd9f93401e67724

echo "End: $(date)"