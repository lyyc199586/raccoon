# bash script to run moose input files automatically

sdlist=(0.5 1)
# plist=(1.4 1.5 1.75 2.0 2.25 2.5 2.75 3.0)
# gclist=(0.6 0.7 0.8 0.9 1.0)
gclist=(0.5)
# gclist=(1.25 1.5 1.75 2.0 2.25 2.5 2.75 3)
for i in ${gclist[@]} ; do

    for j in ${sdlist[@]}; do

    arg1="rz_damage.i gc_ratio="$i" SD="$j

    echo $arg1

    mpirun -n 16 ../../raccoon-opt -i $arg1

    done

done