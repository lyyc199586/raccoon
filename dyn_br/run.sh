echo "Start: $(date)"
echo "cwd: $(pwd)"

nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i > log.txt 2>&1 &

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_nobranch.i > log.txt 2>&1 &

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i sharp.i > log.txt 2>&1 &

echo "End: $(date)"