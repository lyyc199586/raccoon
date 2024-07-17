echo "Start: $(date)"
echo "cwd: $(pwd)"

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i > log.txt 2>&1 &
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity.i > log.txt 2>&1 &

nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_cf_angle.i > log.txt 2>&1 &
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh_cf_angle.i > log.txt 2>&1 &
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh_cf_release.i > log.txt 2>&1 &
# nohup mpirun -n 15 ~/projects/raccoon/raccoon-opt -i elasticity_cf_angle.i  > log.txt 2>&1 &

# wait 

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity_coh_cf_release.i --recover > log.txt 2>&1 &
# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i elasticity.i > log_wait.txt 2>&1 &

# nohup mpirun -n 14 ~/projects/raccoon/raccoon-opt -i sharp.i > log.txt 2>&1 &

echo "End: $(date)"