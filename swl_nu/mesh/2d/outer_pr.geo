x_size = 3.25;
y_size = 2.0;
vgap   = 0.75;
hgap   = 0.25;

h_def_f = 0.02; // mesh size of bottom (impacted fluid-solid interface)
h_def_c = 0.1;  // mesh size of top

// outer frame
Point(1) = {           0,   -0.5*y_size-vgap,           0, h_def_c};
Point(2) = { x_size+hgap,   -0.5*y_size-vgap,           0, h_def_c};
Point(3) = { x_size+hgap,    0.5*y_size+6*vgap,         0, h_def_c};
Point(4) = {           0,    0.5*y_size+6*vgap,         0, h_def_c};
Point(9) = {           0,    0.5*y_size + 1,            0, h_def_f};

// inner frame
Point(5) = {      0, -0.5*y_size,      0, h_def_c};
Point(6) = { x_size, -0.5*y_size,      0, h_def_c};
Point(10) = { x_size,           0,      0, h_def_f};
Point(7) = { x_size,  0.5*y_size,      0, h_def_f};
Point(8) = {      0,  0.5*y_size,      0, h_def_f};

//#####################################################################

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 9};
Line(9) = {9, 8};
Line(5) = {8, 7};
Line(6) = {7, 10};
Line(10) = {10, 6};
Line(7) = {6, 5};
Line(8) = {5, 1};

Line Loop(1) = {1, 2, 3, 4, 9, 5, 6, 10, 7, 8};
Plane Surface(1) = {1};
Physical Surface("all") = {1};

Physical Line("curved") = {6, 10};
Physical Line("top") = {5};
Physical Line("bottom") = {7};
Physical Line("top_bottom") = {5, 7};
Physical Line("inner_BC") = {5, 6, 7};
Physical Line("axial") = {4, 9, 8};
Physical Line("outer_bottom") = {1};
Physical Line("outer_curved") = {2};
Physical Line("outer_top") = {3};

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;