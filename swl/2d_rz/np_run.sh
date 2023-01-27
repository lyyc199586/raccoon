# bash script run rz_damage-2.i multiple pulses with index i, start from 2

for ((i=2; i<21; i++)); do
    arg1="rz_damage-2.i np="$i
    echo $arg1
    mpirun -n 12 ../../raccoon-opt -i $arg1
done