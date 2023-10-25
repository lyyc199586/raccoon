echo "Start: $(date)"
echo "cwd: $(pwd)"

nohup mpirun -n 12 ~/projects/raccoon/raccoon-opt -i elasticity.i > log.txt 2>&1 &

echo "End: $(date)"