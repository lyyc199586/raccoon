x_size = 32;
y_size = 8;
crack_length = 4;
eps = 0.0002;

h_f = 0.05;
h_c = 0.2;

Point(1) = {0, -y_size, 0, h_c};
Point(2) = {x_size, -y_size, 0, h_c};
Point(3) = {x_size, 0, 0, h_f};
Point(4) = {x_size, y_size, 0, h_c};
Point(5) = {0, y_size, 0, h_c};
Point(6) = {0, eps, 0, h_c};
Point(7) = {crack_length, 0, 0, h_f};
Point(8) = {0, -eps, 0, h_c};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 1};
Line(9) = {3, 7};

Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};
Line{9} In Surface{1};

Physical Line("bottom") = {1};
Physical Line("right") = {2, 3};
Physical Line("top") = {4};
Physical Line("left") = {5, 8};
Physical Line("upper_crack") = {6};
Physical Line("lower_crack") = {7};
Physical Point("fix_point") = {1};
Physical Surface("all") = {1};

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;