for delta in 15 20; do
  echo delta=${delta}
  mpirun -n 6 ~/projects/raccoon/raccoon-opt -i elasticity.i delta=${delta} > log_delta${delta}.txt 2>&1 &
done
