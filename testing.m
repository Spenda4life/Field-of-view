clc, clear, close all
   
load('TR.mat');
vertices = TR.Points;
faces = TR.ConnectivityList;

sensor = [[-677 0 134];[-450 75 235]];
radius = 5280*12;
resolution = 250;
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
normals = faceNormal(TR);
OT = OcTree(faceCenters,'binCapacity',round(size(vertices,1)*binCapacity));

% ------------------------------------------------------------------------
% RAY CASTING LOOP
% ------------------------------------------------------------------------

numTargets = size(targets, 1);
numSensors = size(sensor, 1);

tic
parfor i = 1:numTargets
    for j = 1:numSensors
        
        occluded = castRay(OT,sensor(j,:),targets(i,:),vertices,faces);
        
        if ~occluded
            sph(i,:) = [NaN, NaN];
        end
    end
end
toc

tic
parfor i = 1:numTargets
    for j = 1:numSensors
        
        occluded = fastRay(OT,sensor(j,:),targets(i,:),vertices,faces,normals);
        
        if ~occluded
            sph(i,:) = [NaN, NaN];
        end
    end
end
toc