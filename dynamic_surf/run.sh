echo "Start: $(date)"
echo "cwd: $(pwd)"
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_nuc.i > log.txt 2>&1 &
nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i > log.txt 2>&1 &
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i cmp_static.i > log.txt 2>&1 &

echo "End: $(date)"
