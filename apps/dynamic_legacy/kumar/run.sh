echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 12 ~/projects/raccoon/raccoon-opt -i elasticity.i

echo "End: $(date)"