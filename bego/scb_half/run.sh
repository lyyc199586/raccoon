echo "Start: $(date)"
echo "cwd: $(pwd)"
mpirun -n 16 ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"
