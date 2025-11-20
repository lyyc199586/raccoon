import os
import gmsh
import sys
import math

gmsh.initialize()
gmsh.model.add("BegoStone")

p1 = gmsh.model.occ.addPoint(0, 0, 0)
p2 = gmsh.model.occ.addPoint(80, 0, 0)
p3 = gmsh.model.occ.addPoint(150, 0, 0)
p4 = gmsh.model.occ.addPoint(0, 150, 0)
p5 = gmsh.model.occ.addPoint(0, 80, 0)
l1 = gmsh.model.occ.addLine(p2, p3)
l2 = gmsh.model.occ.addCircleArc(p3, p1, p4)
l3 = gmsh.model.occ.addLine(p4, p5)
l4 = gmsh.model.occ.addCircleArc(p5, p1, p2)
loop = gmsh.model.occ.addCurveLoop([l1, l2, l3, l4])
gmsh.model.occ.addPlaneSurface([loop])

gmsh.model.occ.synchronize()

gmsh.model.addPhysicalGroup(1,[1],-1,"bottom")
gmsh.model.addPhysicalGroup(1,[4],-1,"inner")
gmsh.model.addPhysicalGroup(1,[3],-1,"left")
gmsh.model.addPhysicalGroup(2, [1], -1, "Entire_Plane")

# Generate mesh
ent = gmsh.model.getEntities(-1)
gmsh.model.mesh.setSize(ent, 0.5)
# gmsh.model.mesh.setTransfiniteAutomatic(ent)
gmsh.model.mesh.generate(2)

gmsh.write(
    "/home/labuser/projects/MyProject/LaserLithotripsy/2D_quarter_benchmark/mesh.msh"
)

if "-nopopup" not in sys.argv:
    gmsh.fltk.run()

gmsh.finalize()
