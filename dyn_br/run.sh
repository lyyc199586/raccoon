echo "Start: $(date)"
echo "cwd: $(pwd)"

nohup mpirun -n 8 ~/projects/raccoon/raccoon-opt -i elasticity.i --color off > log.txt 2>&1 &

echo "End: $(date)"