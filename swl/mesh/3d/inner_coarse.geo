x_size = 3.25; // [mm]
y_size = 2.0;

h_def_f = 0.1;
h_def_c = 0.1;

Point(1) = {      0, -0.5*y_size,      0, h_def_c};
Point(2) = { x_size, -0.5*y_size,      0, h_def_c};
Point(3) = {      0, -0.5*y_size, x_size, h_def_c};
Point(4) = {      0,  0.5*y_size,      0, h_def_f};
Point(5) = { x_size,  0.5*y_size,      0, h_def_f};
Point(6) = {      0,  0.5*y_size, x_size, h_def_f};

Line(1) = {1, 2};
Circle(2) = {2, 1, 3};
Line(3) = {3, 1};
Line(4) = {4, 5};
Circle(5) = {5, 4, 6};
Line(6) = {6, 4};
Line(7) = {2, 5};
Line(8) = {1, 4};
Line(9) = {3, 6};

Line Loop(1) = {1, 2, 3};
Plane Surface(1) = {1};
Line Loop(2) = {4, 5, 6};
Plane Surface(2) = {2};
Line Loop(3) = {8, 4, -7, -1};
Plane Surface(3) = {3};
Line Loop(4) = {6, -8, -3, 9};
Plane Surface(4) = {4};
Line Loop(5) = {5, -9, -2, 7};
Ruled Surface(5) = {5};

Physical Surface("back") = {3};
Physical Surface("curved") = {5};
Physical Surface("top") = {2};
Physical Surface("left") = {4};
Physical Surface("bottom") = {1};
Physical Surface("top_bottom") = {1, 2};
Physical Surface("outer_BC") = {1, 2, 5};

Surface Loop(1) = {1, 2, 3, 4, 5};
Volume(1) = {1};

Physical Volume("all") = {1};
