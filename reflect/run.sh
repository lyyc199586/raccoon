echo "Start: $(date)"
echo "cwd: $(pwd)"

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i solid-pd-crack.i > log.txt 2>&1 &
nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i solid-free-surface.i > log.txt 2>&1 &

echo "End: $(date)"