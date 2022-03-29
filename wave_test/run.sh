echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 2 ~/projects/raccoon/raccoon-opt -i elastodynamic.i
# ~/projects/raccoon/raccoon-opt -i elastodynamic.i

echo "End: $(date)"