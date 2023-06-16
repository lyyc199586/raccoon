for gc in 8e-3 8.5e-3 9e-3 9.5e-3 10e-3; do
  echo Gc=${gc}
  ~/projects/raccoon/raccoon-opt -i elasticity.i Gc=${gc} > log_gc${gc}.txt 2>&1 &
done