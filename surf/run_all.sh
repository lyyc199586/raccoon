for gc in 8e-3 8.5e-3 9e-3 9.5e-3 10e-3; do
  echo Gc=${gc}
  mpirun -n 3 ~/projects/raccoon/raccoon-opt -i elasticity.i Gc=${gc} 1>/dev/null 2>/dev/null &
done