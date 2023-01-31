// settings
h = 0.25;
R = 2.9/Sqrt(2);
a = R/2;

// center of the circle
Point(1) = {0,0,0,h};

// 4 control points on axis
Point(2) = {R,R,0,h};
Point(3) = {-R,R,0,h};
Point(4) = {-R,-R,0,h};
Point(5) = {R,-R,0,h};

// 4 inner points on sqaure
Point(6) = {a,a,0,h};
Point(7) = {-a,a,0,h};
Point(8) = {-a,-a,0,h};
Point(9) = {a,-a,0,h};

// top and bottom points
Point(10) = {0, 2.9, 0, h};
Point(11) = {0, -2.9, 0, h};

// 4 arcs
Circle(1) = {2,1,3};
Circle(2) = {3,1,4};
Circle(3) = {4,1,5};
Circle(4) = {5,1,2};

// 4 inner lines
Line(5) = {6, 7};
Line(6) = {7, 8};
Line(7) = {8, 9};
Line(8) = {9, 6};

// 4 connect lines
Line(9) = {2, 6};
Line(10) = {3, 7};
Line(11) = {4, 8};
Line(12) = {5, 9};

// center square
Line Loop(1) = {5, 6, 7, 8};
Plane Surface(1) = {1};

// 4 outer plane
Curve Loop(2) = {4, 9, -8, -12};
Plane Surface(2) = {2};

Curve Loop(3) = {1, 10, -5, -9};
Plane Surface(3) = {3};

Curve Loop(4) = {2, 11, -6, -10};
Plane Surface(4) = {4};

Curve Loop(5) = {3, 12, -7, -11};
Plane Surface(5) = {5};

Point{1, 10, 11} In Surface {1};

// Line{5, 6, 7, 8} In Surface {1};

// structure mesh
Transfinite Line {1,2,3,4,5,6,7,8,9,10,11,12} = 13 Using Progression 1; //2.9/0.25=11.6
// Transfinite Line {6, 8} = 117 Using Progression 1;
Transfinite Surface{1, 2, 3, 4, 5};
Recombine Surface{1, 2, 3, 4, 5};

// marker
// Physical Surface("all") = {1, 2, 3, 4, 5};
// Physical Point("top") = {10};
// Physical Point("bottom") = {11};

// Geometry.PointNumbers = 1;
// Geometry.LineNumbers = 1;
// Geometry.SurfaceNumbers = 1;

Recombine Surface {:};

// extrude z = 3.5 mm
Extrude {0, 0, 3.5} { 
  Surface{1,2,3,4,5}; Layers {15}; Recombine; // 3.5/0.25=14
}