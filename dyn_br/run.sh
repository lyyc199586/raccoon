echo "Start: $(date)"
echo "cwd: $(pwd)"

nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity.i --recover --color off > log.txt 2>&1 &

echo "End: $(date)"