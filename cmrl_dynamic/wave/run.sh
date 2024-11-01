echo "Start: $(date)"
echo "cwd: $(pwd)"

nohup mpirun -n 16 ~/projects/raccoon/raccoon-opt -i elastodynamic.i > log.txt 2>&1 & --recover

echo "End: $(date)"