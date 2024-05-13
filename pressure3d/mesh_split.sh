echo "Start: $(date)"
echo "cwd: $(pwd)"

~/projects/raccoon/raccoon-opt -i elasticity.i --split-mesh 12 --split-file split12.cpr

echo "End: $(date)"