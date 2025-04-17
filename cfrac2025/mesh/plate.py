import gmsh
import math

# Geometry parameters
Lx = 140.0
Ly = 70.0
r = 15.0
cx = 45.0
cy = 0.0
crack_len = 15.0
crack_width = 0.01
load_height = 40.0
mesh_size = 1.0

def build_geometry():
    # gmsh.model.occ.clear()

    # 1. Plate
    plate = gmsh.model.occ.addRectangle(0, -Ly/2, 0, Lx, Ly)

    # 2. Circle from 4 arcs
    top    = gmsh.model.occ.addPoint(cx, cy + r, 0, mesh_size)
    right  = gmsh.model.occ.addPoint(cx + r, cy, 0, mesh_size)
    bottom = gmsh.model.occ.addPoint(cx, cy - r, 0, mesh_size)
    left   = gmsh.model.occ.addPoint(cx - r, cy, 0, mesh_size)
    center = gmsh.model.occ.addPoint(cx, cy, 0, mesh_size)

    arc1 = gmsh.model.occ.addCircleArc(right, center, top)
    arc2 = gmsh.model.occ.addCircleArc(top, center, left)
    arc3 = gmsh.model.occ.addCircleArc(left, center, bottom)
    arc4 = gmsh.model.occ.addCircleArc(bottom, center, right)

    hole_loop = gmsh.model.occ.addCurveLoop([arc1, arc2, arc3, arc4])
    hole_surface = gmsh.model.occ.addPlaneSurface([hole_loop])

    # 3. Crack rectangle — left points lie on the circle
    alpha = math.asin(crack_width / (2 * r))
    y_top = cy + r * math.sin(alpha)
    y_bot = cy - r * math.sin(alpha)
    x_left = cx + r * math.cos(alpha)  # horizontal pos of intersection
    x_right = x_left + crack_len

    # Add crack rectangle points
    p_lt = gmsh.model.occ.addPoint(x_left, y_top, 0, mesh_size / 2)
    p_rt = gmsh.model.occ.addPoint(x_right, y_top, 0, mesh_size / 2)
    p_rb = gmsh.model.occ.addPoint(x_right, y_bot, 0, mesh_size / 2)
    p_lb = gmsh.model.occ.addPoint(x_left, y_bot, 0, mesh_size / 2)

    l1 = gmsh.model.occ.addLine(p_lb, p_rb)
    l2 = gmsh.model.occ.addLine(p_rb, p_rt)
    l3 = gmsh.model.occ.addLine(p_rt, p_lt)
    l4 = gmsh.model.occ.addLine(p_lt, p_lb)

    crack_loop = gmsh.model.occ.addCurveLoop([l1, l2, l3, l4])
    crack_surface = gmsh.model.occ.addPlaneSurface([crack_loop])

    # 4. Cut plate minus hole and crack
    cut1 = gmsh.model.occ.cut([(2, plate)], [(2, hole_surface)], removeObject=True, removeTool=True)
    cut2 = gmsh.model.occ.cut(cut1[0], [(2, crack_surface)], removeObject=True, removeTool=True)

    gmsh.model.occ.synchronize()

    assert cut2[0], "Boolean cut failed"
    _, surface_tag = cut2[0][0]

    gmsh.model.addPhysicalGroup(2, [surface_tag], 1)
    gmsh.model.setPhysicalName(2, 1, "domain")

    # 5. Tag boundary edges
    crack_edges = []

    for dim, tag in gmsh.model.getEntities(1):
        x, y, _ = gmsh.model.occ.getCenterOfMass(dim, tag)
        if abs(x) < 1e-6:
            gmsh.model.addPhysicalGroup(1, [tag], 1)
            gmsh.model.setPhysicalName(1, 1, "left")
        elif x_left <= x <= x_right and abs(y) <= crack_width:
            crack_edges.append(tag)
        elif abs(x - Lx) < 1e-6:
            gmsh.model.addPhysicalGroup(1, [tag], 2)
            gmsh.model.setPhysicalName(1, 2, "right")
        elif abs(y - Ly / 2) < 1e-6:
            gmsh.model.addPhysicalGroup(1, [tag], 3)
            gmsh.model.setPhysicalName(1, 3, "top")
        elif abs(y + Ly / 2) < 1e-6:
            gmsh.model.addPhysicalGroup(1, [tag], 4)
            gmsh.model.setPhysicalName(1, 4, "bottom")


    gmsh.model.addPhysicalGroup(1, crack_edges, 5)
    gmsh.model.setPhysicalName(1, 5, "crack")


def main():
    gmsh.initialize()
    gmsh.model.add("plate")
    build_geometry()
    gmsh.option.setNumber("Mesh.Algorithm", 6)  # Delaunay
    gmsh.model.mesh.setSize(gmsh.model.getEntities(0), mesh_size)
    gmsh.model.mesh.generate(2)
    gmsh.write(f"plate_h{mesh_size}.msh")
    gmsh.fltk.run()
    gmsh.finalize()

if __name__ == "__main__":
    main()
