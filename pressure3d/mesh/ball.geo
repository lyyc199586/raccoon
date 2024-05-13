r = 80;
R = 120;
h = 0.5;

a = r/Sqrt(3);
b = R/Sqrt(3);

Point(1)   = {0, 0, 0, h};
Point(2)   = {r, 0, 0, h};
Point(3)   = {R, 0, 0, h};
Point(4)   = {0, r, 0, h};
Point(5)   = {0, R, 0, h};
Point(6)   = {0, 0, r, h};
Point(7)   = {0, 0, R, h};
Point(8)   = {r*Cos(Pi/4),r*Cos(Pi/4),0,  h};      // XY Plane inner sphere
Point(9)   = {R*Cos(Pi/4),R*Cos(Pi/4),0,  h};  // XY Plane outer sphere
Point(10)  = {0, r*Cos(Pi/4),r*Cos(Pi/4), h};      // YZ Plane inner sphere
Point(11)  = {0, R*Cos(Pi/4),R*Cos(Pi/4), h};  // YZ Plane outer sphere
Point(12)  = {r*Cos(Pi/4), 0,r*Cos(Pi/4), h};      // XZ Plane inner sphere
Point(13)  = {R*Cos(Pi/4), 0,R*Cos(Pi/4), h}; // XZ Plane outer sphere
Point(14)  = {a, a, a, h};
Point(15)  = {b, b, b, h};

Line(1) = {2, 3};
Line(2) = {4, 5};
Line(3) = {6, 7};
Line(4) = {8, 9};
Line(5) = {10, 11};
Line(6) = {12, 13};
Circle(7) = {2, 1, 12};
Circle(8) = {12, 1, 6};
Circle(9) = {6, 1, 10};
Circle(10) = {10, 1, 4};
Circle(11) = {4, 1, 8};
Circle(12) = {8, 1, 2};
Circle(13) = {3, 1, 13};
Circle(14) = {13, 1, 7};
Circle(15) = {7, 1, 11};
Circle(16) = {11, 1, 5};
Circle(17) = {5, 1, 9};
Circle(18) = {9, 1, 3};
Circle(19) = {12, 1, 14};
Circle(20) = {14, 1, 8};
Circle(21) = {14, 1, 10};
Circle(22) = {13, 1, 15};
Circle(23) = {15, 1, 9};
Circle(24) = {15, 1, 11};
Line(37) = {14, 15};

Line Loop(25) = {16, -2, -10, 5};
Plane Surface(26) = {25};
Line Loop(27) = {15, -5, -9, 3};
Plane Surface(28) = {27};
Line Loop(29) = {2, 17, -4, -11};
Plane Surface(30) = {29};
Line Loop(31) = {4, 18, -1, -12};
Plane Surface(32) = {31};
Line Loop(33) = {3, -14, -6, 8};
Plane Surface(34) = {33};
Line Loop(35) = {6, -13, -1, 7};
Plane Surface(36) = {35};
Line Loop(38) = {22, -37, -19, 6};
Plane Surface(39) = {38};
Line Loop(40) = {37, 23, -4, -20};
Plane Surface(41) = {40};
Line Loop(42) = {24, -5, -21, 37};
Plane Surface(43) = {42};
Line Loop(44) = {21, -9, -8, 19};
Ruled Surface(45) = {44};
Line Loop(46) = {21, 10, 11, -20};
Ruled Surface(47) = {46};
Line Loop(48) = {19, 20, 12, 7};
Ruled Surface(49) = {48};
Line Loop(50) = {22, 24, -15, -14};
Ruled Surface(51) = {50};
Line Loop(52) = {13, 22, 23, 18};
Ruled Surface(53) = {52};
Line Loop(54) = {23, -17, -16, -24};
Ruled Surface(55) = {54};

Surface Loop(56) = {53, 36, 32, 49, 41, 39};
Volume(57) = {56};
Surface Loop(58) = {51, 28, 45, 34, 43, 39};
Volume(59) = {58};
Surface Loop(60) = {30, 26, 55, 47, 43, 41};
Volume(61) = {60};

dx = h;
nx = Floor((R - r)/dx) + 1; // axial
ny = Floor((R + r)*3.14/8/dx) + 1; // radial
Transfinite Line {1,2,3,4,5,6,37}       = nx Using Progression 1;
Transfinite Line {9,12,15,18,19,22}     = ny Using Progression 1;
Transfinite Line {20,21,23,24,10,11,16,17,7,8,13,14} = ny Using Progression 1;

Transfinite Surface {26,28,30,32,34,36,39,41,43,45,47,49,51,53,55};
Recombine Surface {26,28,30,32,34,36,39,41,43,45,47,49,51,53,55};

Transfinite Volume {57,59,61};
Recombine Volume {57,59,61};

// mark boundary side
Physical Surface("inner") = {45, 47, 49};
Physical Surface("outer") = {51, 53, 55};
Physical Surface("bottom") = {34, 36};
Physical Surface("left") = {26, 28};
Physical Surface("back") = {30, 32};
Physical Volume("ball") = {57, 59, 61};

// show mesh info
Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;