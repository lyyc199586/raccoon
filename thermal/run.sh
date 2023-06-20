echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 14 ~/projects/raccoon/raccoon-opt -i tube.i

echo "End: $(date)"