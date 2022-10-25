echo "Start: $(date)"
echo "cwd: $(pwd)"
mpirun -n 16 ~/projects/raccoon/raccoon-opt -i indenter_rz_nodeface_friction.i

echo "End: $(date)"
