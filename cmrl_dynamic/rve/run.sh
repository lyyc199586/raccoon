echo "Start: $(date)"
echo "cwd: $(pwd)"

nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i dynamic_fracture.i > log.txt 2>&1 &

echo "End: $(date)"