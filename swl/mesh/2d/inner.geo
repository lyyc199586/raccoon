x_size = 3.25;
y_size = 2.0;

h_def_f = 0.02; // mesh size of top (impacted solid-fluid interface)
h_def_c = 0.1;  // mesh size of bottom 

Point(1) = {      0, -0.5*y_size,      0, h_def_c};
Point(2) = { x_size, -0.5*y_size,      0, h_def_c};
Point(3) = { x_size,  0.5*y_size,      0, h_def_f};
Point(4) = {      0,  0.5*y_size,      0, h_def_f};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};
Physical Surface("all") = {1};

Physical Line("bottom") = {1};
Physical Line("top") = {3};
Physical Line("axial") = {4};
Physical Line("curved") = {2};
Physical Line("outer_BC") = {1, 2, 3}

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;
