
% Michael Hansell
% Updated February 8, 2023
% 
% This script uses a CAD model and one or more viewpoint 
% coordinates to generate a field of view / field of regard plot. A radius
% input is used to convey a visability requirement, i.e. full
% visability beyond some distance from the model. The resolution variable 
% determines elevation and azimuth resolution and can significantly impact 
% runtime.
%
% Use processSTL.m to generate a triangulation from an STL file
% The quality of the triangulation will greatly affect the performance of
% this script so it is worth the upfront time to refine the model
% A very large number of triangles (>10^6) or high aspect ratio triangles
% can cause issues.

clc, clear, close all
tic

% ------------------------------------------------------------------------
% USER DEFINED VARIABLES
% ------------------------------------------------------------------------

% LOAD(file)	.MAT file containing triangulation of a CAD model
% SENSOR      	XYZ coordinates for sensor location. If there are multiple 
%               sensors format as an Nx3 matrix.
% RADIUS        Minimum viewing distance in inches
% RESOLUTION    Resolution determines number of sample points/rays that 
%               are checked. Number is (resolution + 1)^2
% BINCAPACITY   Maximum number of points per bin in the Octree. This is
%               expressed as a percent of total points.
     
load('TR.mat');
vertices = TR.Points;
faces = TR.ConnectivityList;

% sensor = [[-677 0 134];[-450 75 235]];
sensor = [-677 0 134];
radius = 5280*12;
resolution = 100;
binCapacity = 0.01;

% ------------------------------------------------------------------------
% GENERATE VIEWPOINT TARGETS
% ------------------------------------------------------------------------

[x, y, z] = sphere(resolution);
[az, el, ~] = cart2sph(x(:),y(:),z(:));
sph = [rad2deg(az) rad2deg(el)];
targets = [x(:) y(:) z(:)] * radius + mean(vertices);

% ------------------------------------------------------------------------
% BUILD BOUNDING VOLUME HIERARCHY
% ------------------------------------------------------------------------

faceCenters = incenter(TR);
OT = OcTree(faceCenters,'binCapacity',round(size(vertices,1)*binCapacity));

% ------------------------------------------------------------------------
% RAY CASTING LOOP
% ------------------------------------------------------------------------

numTargets = size(targets, 1);
numSensors = size(sensor, 1);
parfor i = 1:numTargets
    for j = 1:numSensors
        
        occluded = castRay(OT, sensor(j,:), targets(i,:), vertices, faces);
        
        if ~occluded
            sph(i,:) = [NaN, NaN];
        end
    end
end

toc

% ------------------------------------------------------------------------
% RESULTS
% ------------------------------------------------------------------------

% sensor location
tiledlayout(1,3);
nexttile(1)
patch('Faces', faces, 'Vertices', vertices,...
    'FaceColor', [0.65 0.65 0.65], 'EdgeColor', [0.5 0.5 0.5])
hold on
for i = 1:size(sensor, 1)
    scatter3(sensor(i,1), sensor(i,2), sensor(i,3),...
        100, 'blue', 'filled')
end
title('Sensor Location')
view([45 25])
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal

% field of view
nexttile(2, [1 2]);
scatter(sph(:,1),sph(:,2),'r','filled');
title('Occulded Field of View')
xlabel('Azimuth');
ylabel('Elevation');
axis([-180 180 -90 90])

% ------------------------------------------------------------------------
% END OF SCRIPT
% ------------------------------------------------------------------------