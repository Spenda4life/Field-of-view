% load stl
TR = stlread('C:\Users\Michael.Hansell\Desktop\c130_2.stl');
f = TR.ConnectivityList;

% rotate and scale vertices -- this will be unique to each STL
v = TR.Points ./ 25.4;

% reduce number of triangles -- reduction factor based on unique need
reductionFactor = 0.1;
[nf,nv] = reducepatch(f,v,reductionFactor,'verbose'); 

% create new triangulation and plot mesh
TR = triangulation(nf,nv);
trimesh(TR)