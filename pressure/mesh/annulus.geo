// Define the radii
r1 = 80;  // Inner radius
r2 = 120;  // Outer radius
h = 4;

// Create points
Point(1) = {0, 0, 0, h};
Point(2) = {r1, 0, 0, h};
Point(3) = {r2, 0, 0, h};
Point(4) = {0, r1, 0, h};
Point(5) = {0, r2, 0, h};

// Create arcs
Circle(1) = {2, 1, 4};
Circle(2) = {3, 1, 5};

// Create lines
Line(3) = {2, 3};
Line(4) = {4, 5};

// Define line loop and surface
Curve Loop(1) = {1, 4, -2, -3};
Plane Surface(1) = {1};

// Transfinite meshing
nx = Floor((r2-r1)/h) + 1;
ny = Floor(0.5*3.1415*(r1+r2)/2/h) + 1;
Transfinite Line{1, 2} = ny Using Progression 1;
Transfinite Line{3, 4} = nx Using Progression 1;
Transfinite Surface{1};
Recombine Surface{1};

// mark boundary
Physical Line("bottom") = {3};
Physical Line("left") = {4};
Physical Curve("inner") = {1};
Physical Curve("outer") = {2};
Physical Surface("annulus") = {1};

Geometry.PointNumbers = 1;
Geometry.LineNumbers = 1;
Geometry.SurfaceNumbers = 1;

Mesh 2;
