x_size = 32;
y_size = 8;
crack_length = 4;

h_f = 0.05;
h_c = 0.2;

Point(1) = {0, 0, 0, h_f};
Point(2) = {crack_length, 0, 0, h_f};
Point(3) = {x_size, 0, 0, h_f};
Point(4) = {x_size, y_size, 0, h_c};
Point(5) = {0, y_size, 0, h_c};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 1};

Line Loop(1) = {1, 2, 3, 4, 5};
Plane Surface(1) = {1};

// Physical Line("crack") = {1};
// Physical Line("center") = {2};
Physical Line("right") = {3};
Physical Line("top") = {4};
Physical Line("left") = {5};
Physical Surface("all") = {1};

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;