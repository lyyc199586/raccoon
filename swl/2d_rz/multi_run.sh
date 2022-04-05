# bash script to run moose input files automatically

sdlist=(0.5 0.75 1)
plist=(1.4 1.5 1.75 2.0 2.25 2.5 2.75 3.0)
for i in ${plist[@]} ; do

    for j in ${sdlist[@]}; do

    arg1="rz_damage.i p_max="$i" SD="$j

    echo $arg1

    mpirun -n 16 ../../raccoon-opt -i $arg1

    done

done