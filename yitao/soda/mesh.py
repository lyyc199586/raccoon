import os
import gmsh
import sys
import math

gmsh.initialize()
gmsh.model.add("Soda-lime")

p1 = gmsh.model.occ.addPoint(19, 0, 0)
p2 = gmsh.model.occ.addPoint(100, 0, 0)
p3 = gmsh.model.occ.addPoint(100, 75, 0)
p4 = gmsh.model.occ.addPoint(0, 75, 0)
p5 = gmsh.model.occ.addPoint(0, 6.915, 0)
l1 = gmsh.model.occ.addLine(p1, p2)
l2 = gmsh.model.occ.addLine(p2, p3)
l3 = gmsh.model.occ.addLine(p3, p4)
l4 = gmsh.model.occ.addLine(p4, p5)
l5 = gmsh.model.occ.addLine(p5, p1)
loop = gmsh.model.occ.addCurveLoop([l1, l2, l3, l4, l5])
plane = gmsh.model.occ.addPlaneSurface([loop])

p6 = gmsh.model.occ.addPoint(50, 0, 0)
p7 = gmsh.model.occ.addPoint(100, 25, 0)
l6 = gmsh.model.occ.addLine(p6, p7)

gmsh.model.occ.synchronize()

gmsh.model.addPhysicalGroup(1,[1],-1,"center")
gmsh.model.addPhysicalGroup(1, [3], -1, "top")
gmsh.model.addPhysicalGroup(1, [5], -1, "v-entire")
gmsh.model.addPhysicalGroup(2, [1], -1, "Entire_Plane")

# Generate mesh
gmsh.model.mesh.field.add("Distance", 1)
gmsh.model.mesh.field.setNumbers(1, "CurvesList", [6])
gmsh.model.mesh.field.setNumber(1, "Sampling", 100)

gmsh.model.mesh.field.add("Threshold", 2)
gmsh.model.mesh.field.setNumber(2, "InField", 1)
gmsh.model.mesh.field.setNumber(2, "SizeMin", 0.1)
gmsh.model.mesh.field.setNumber(2, "SizeMax", 2)
gmsh.model.mesh.field.setNumber(2, "DistMin", 0)
gmsh.model.mesh.field.setNumber(2, "DistMax", 50)

gmsh.model.mesh.field.setAsBackgroundMesh(2)
gmsh.model.mesh.setRecombine(2, plane)

gmsh.model.mesh.generate(2)

gmsh.write(
    "./mesh.msh"
)

if "-nopopup" not in sys.argv:
    gmsh.fltk.run()

gmsh.finalize()
