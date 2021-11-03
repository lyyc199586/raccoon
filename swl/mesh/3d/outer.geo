x_size = 3.25;
y_size = 2.0;
gap    = 0.75;

h_def_f = 0.02; // mesh size of bottom (impacted fluid-solid interface)
h_def_c = 0.1;  // mesh size of top

//#####################################################################
Point(1) = {           0,   -0.5*y_size-gap,           0, h_def_c};
Point(2) = { x_size+0.25,   -0.5*y_size-gap,           0, h_def_c};
Point(3) = {           0,   -0.5*y_size-gap, x_size+0.25, h_def_c};
Point(4) = {           0,  0.5*y_size+6*gap,           0, h_def_c};
Point(5) = { x_size+0.25,  0.5*y_size+6*gap,           0, h_def_c};
Point(6) = {           0,  0.5*y_size+6*gap, x_size+0.25, h_def_c};

//#####################################################################
Point(7)  = {      0, -0.5*y_size,      0, h_def_c};
Point(8)  = { x_size, -0.5*y_size,      0, h_def_c};
Point(9)  = {      0, -0.5*y_size, x_size, h_def_c};
Point(10) = {      0,  0.5*y_size,      0, h_def_f};
Point(11) = { x_size,  0.5*y_size,      0, h_def_f};
Point(12) = {      0,  0.5*y_size, x_size, h_def_f};

//#####################################################################

Line(1) = {1, 2};
Circle(2) = {2, 1, 3};
Line(3) = {3, 1};
Line(4) = {4, 5};
Circle(5) = {5, 4, 6};
Line(6) = {6, 4};
Line(13) = {2, 5};
Line(14) = {3, 6};
Line(7) = {7, 8};
Circle(8) = {8, 7, 9};
Line(9) = {9, 7};
Line(10) = {10, 11};
Circle(11) = {11, 10, 12};
Line(12) = {12, 10};
Line(17) = {8, 11};
Line(18) = {9, 12};
Line(15) = {1, 7};
Line(16) = {10, 4};

Line Loop(1) = {1, 2, 3};
Plane Surface(1) = {1};
Line Loop(2) = {4, 5, 6};
Plane Surface(2) = {2};
Line Loop(3) = {4, -13, -1, 15, 7, 17, -10, 16};
Plane Surface(3) = {3};
Line Loop(4) = {6, -16, -12, -18, 9, -15, -3, 14};
Plane Surface(4) = {4};
Line Loop(5) = {7, 8, 9};
Plane Surface(5) = {5};
Line Loop(6) = {10, 11, 12};
Plane Surface(6) = {6};
Line Loop(7) = {2, 14, -5, -13};
Ruled Surface(7) = {7};
Line Loop(8) = {8, 18, -11, -17};
Ruled Surface(8) = {8};

Physical Surface("curved") = {8};
Physical Surface("top") = {6};
Physical Surface("bottom") = {5};
Physical Surface("top_bottom") = {5, 6};
Physical Surface("inner_BC") = {5, 6, 8};

Surface Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Volume(1) = {1};

Physical Volume("all") = {1};

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;
