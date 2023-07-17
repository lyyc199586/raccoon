for gc in 12e-3 15e-3; do
  echo Gc=${gc}
  mpirun -n 6 ~/projects/raccoon/raccoon-opt -i elasticity.i Gc=${gc} > log_gc${gc}.txt 2>&1 &
done
