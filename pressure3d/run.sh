echo "Start: $(date)"
echo "cwd: $(pwd)"
nohup mpirun -n 4 ~/projects/raccoon/raccoon-opt -i elasticity.i --trap-fpe > log.txt 2>&1 &

echo "End: $(date)"