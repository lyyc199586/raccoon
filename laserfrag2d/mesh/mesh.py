import os
import gmsh
import sys
import math

gmsh.initialize()
gmsh.model.add("BegoStone")

# p1 = gmsh.model.occ.addPoint(0, 0, 0)
# p2 = gmsh.model.occ.addPoint(3, 0, 0)
# p3 = gmsh.model.occ.addPoint(3, 0, 3)
# p4 = gmsh.model.occ.addPoint(0.42, 0, 3)
# p5 = gmsh.model.occ.addPoint(0.42, 0, 2.28)
# p6 = gmsh.model.occ.addPoint(0, 0, 2.28)
# l1 = gmsh.model.occ.addLine(p1, p2)
# l2 = gmsh.model.occ.addLine(p2, p3)
# l3 = gmsh.model.occ.addLine(p3, p4)
# l4 = gmsh.model.occ.addLine(p4, p5)
# l5 = gmsh.model.occ.addLine(p5, p6)
# l6 = gmsh.model.occ.addLine(p6, p1)
# loop = gmsh.model.occ.addCurveLoop([l1, l2, l3, l4, l5, l6])
# plane = gmsh.model.occ.addPlaneSurface([loop])
# gmsh.model.occ.revolve([(2, 1)], 0, 0, 0, 0, 0, 1, math.pi/2)
circle = gmsh.model.occ.addCircle(0, 0, 0, 3)
crater = gmsh.model.occ.addCircle(0, 0, 0, 0.42)
loop1 = gmsh.model.occ.addCurveLoop([circle])
plane1 = gmsh.model.occ.addPlaneSurface([loop1])
loop2 = gmsh.model.occ.addCurveLoop([crater])
plane2 = gmsh.model.occ.addPlaneSurface([loop2])

gmsh.model.occ.cut([(2, plane1)], [(2, plane2)])

gmsh.model.occ.synchronize()

gmsh.model.addPhysicalGroup(1,[2],-1,"inner")
# gmsh.model.addPhysicalGroup(0, [15, 13, 16, 19], -1, "bottom_points")
# gmsh.model.addPhysicalGroup(1, [21, 22, 27, 29], -1, "bottom_edges")
gmsh.model.addPhysicalGroup(2, [1], -1, "Entire_Plane")

# Generate mesh
ent = gmsh.model.getEntities(-1)
gmsh.model.mesh.setSize(ent, 0.1)
# gmsh.model.mesh.setTransfiniteAutomatic(ent)
gmsh.model.mesh.generate(3)

gmsh.write(
    "/home/labuser/projects/MyProject/LaserLithotripsy/LL_crater_2Dintersection/mesh.msh"
)

if "-nopopup" not in sys.argv:
    gmsh.fltk.run()

gmsh.finalize()
