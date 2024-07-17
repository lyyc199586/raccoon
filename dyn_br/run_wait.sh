echo "Start: $(date)"
echo "cwd: $(pwd)"

wait 673311
nohup mpirun -n 15 ~/projects/raccoon/raccoon-opt -i elasticity.i > log_wait.txt 2>&1 &

echo "End: $(date)"