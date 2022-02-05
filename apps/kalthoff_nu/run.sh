echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 8 ~/projects/raccoon/raccoon-opt -i mechanical_nu.i

echo "End: $(date)"