for v0 in {-1e4,-2e4,-5e4}; do
  echo v0=${v0}
  nohup mpirun -n 3 ~/projects/raccoon/raccoon-opt -i elasticity_coh.i v0=${v0} > log_v0${v0}.txt 2>&1 &
done
