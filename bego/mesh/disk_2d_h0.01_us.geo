// settings
e = 0.01;
E = 0.1;
R = 2.9;

// center of the circle
Point(1) = {0,0,0,e};

// 4 control points on axis
Point(2) = {R,0,0,e};
Point(3) = {0,R,0,e};
Point(4) = {-R,0,0,e};
Point(5) = {0,-R,0,e};

// 4 arcs
Circle(1) = {2,1,3};
Circle(2) = {3,1,4};
Circle(3) = {4,1,5};
Circle(4) = {5,1,2};

// 4 lines
// Line(5) = {1, 2};
// Line(6) = {1, 3};
// Line(7) = {1, 4};
// Line(8) = {1, 5};

// 4 quat circle
// Line Loop(1) = {5, 1, -6};
// Plane Surface(1) = {1};

// Line Loop(2) = {6, 2, -7};
// Plane Surface(2) = {2};

// Line Loop(3) = {7, 3, -8};
// Plane Surface(3) = {3};

// Line Loop(4) = {8, 4, -5};
// Plane Surface(4) = {4};

Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};
Recombine Surface{1};

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;