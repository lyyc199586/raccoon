// settings
a = 100;
r = 5;
h_r = 0.125;
h_c = 1;

// center
Point(1) = {0, 0, 0, h_r};

// 4 control points for circle
Point(2) = {r/Sqrt(2), r/Sqrt(2), 0, h_r};
Point(3) = {-r/Sqrt(2), r/Sqrt(2), 0, h_r};
Point(4) = {-r/Sqrt(2), -r/Sqrt(2), 0, h_r};
Point(5) = {r/Sqrt(2), -r/Sqrt(2), 0, h_r};

// 4 points for square plate
Point(6) = {a/2, a/2, 0, h_c};
Point(7) = {-a/2, a/2, 0, h_c};
Point(8) = {-a/2, -a/2, 0, h_c};
Point(9) = {a/2, -a/2, 0, h_c};

// 4 arcs of cicle
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 4};
Circle(3) = {4, 1, 5};
Circle(4) = {5, 1, 2};

// 4 sides of square
Line(5) = {6, 7};
Line(6) = {7, 8};
Line(7) = {8, 9};
Line(8) = {9, 6};

// 4 connection lines
Line(9) = {2, 6};
Line(10) = {3, 7};
Line(11) = {4, 8};
Line(12) = {5, 9};

// 4 sections
Curve Loop(1) = {-1, 9, 5, -10};
Curve Loop(2) = {-2, 10, 6, -11};
Curve Loop(3) = {-3, 11, 7, -12};
Curve Loop(4) = {-4, 12, 8, -9};

Plane Surface(1) = {1};
Plane Surface(2) = {2};
Plane Surface(3) = {3};
Plane Surface(4) = {4};

Physical Line("circle") = {1, 2, 3, 4};
Physical Line("top") = {5};
Physical Line("left") = {6};
Physical Line("bottom") = {7};
Physical Line("right") = {8};

Recombine Surface{1, 2, 3, 4};

Physical Surface(1) = {1, 2, 3, 4};