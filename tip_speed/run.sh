echo "Start: $(date)"
echo "cwd: $(pwd)"

rm -rf .jitcache
nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i solve.i --color off > log.txt 2>&1 &

echo "End: $(date)"