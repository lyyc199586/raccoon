echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i --split-mesh 4 --split-file split4.cpr

echo "End: $(date)"