echo "Start: $(date)"
echo "cwd: $(pwd)"
# nohup mpirun -n 4 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i --use-split --split-file split4.cpr > log.txt 2>&1 &

nohup mpirun -n 4 ~/projects/raccoon/raccoon-opt -i elasticity.i  > log.txt 2>&1 &

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i > log.txt 2>&1 &
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_wu.i > log.txt 2>&1 &

echo "End: $(date)"