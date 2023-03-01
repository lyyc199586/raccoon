echo "Start: $(date)"
echo "cwd: $(pwd)"
mpirun -n 8 ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"