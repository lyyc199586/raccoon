# bash script run rz_damage-2.i multiple pulses with index i, start from 2

# mpirun -n 14 ../../raccoon-opt -i rz_damage.i --color off > log.txt 2>&1 &

for ((i=11; i<21; i++)); do
    arg1="rz_damage-2.i np=$i"
    echo $arg1
    mpirun -n 14 ../../raccoon-opt -i $arg1 --color off > "log_$i.txt" 2>&1 
done