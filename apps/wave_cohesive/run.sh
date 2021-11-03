echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 16 ~/projects/raccoon/raccoon-opt -i elastodynamic.i

echo "End: $(date)"