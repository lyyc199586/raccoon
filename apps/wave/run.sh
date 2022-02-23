echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 4 ~/projects/raccoon/raccoon-opt -i elastodynamic.i

echo "End: $(date)"