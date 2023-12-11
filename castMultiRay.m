function blind = castMultiRay(OT, orig, dir, vertices, faces)

    binPoints = false(size(OT.Points,1),1);
    hits = 0;
    
    for j = 1:size(orig,1)
        origin = orig(j,:);
        traverseTree(1);
        
        if any(binPoints)
            [intersections, ~, ~, ~, ~] = ...
                TriangleRayIntersection(origin, dir,...
                vertices(faces(binPoints,1),:),...
                vertices(faces(binPoints,2),:),...
                vertices(faces(binPoints,3),:));
            hit = sum(intersections) > 0;
        end
    end
    
    blind = hits == size(orig,1);
    
    function traverseTree(currentBin)

        [intersect ,~] = rayBoxIntersection(origin, dir,...
            OT.BinBoundaries(currentBin, 1:3),...
            OT.BinBoundaries(currentBin, 4:6));

        if intersect
            childBinIndices = find(OT.BinParents == currentBin);
            if any(childBinIndices)
                for i = 1:length(childBinIndices)
                    traverseTree(childBinIndices(i))
                end
            else
                binPoints = binPoints | (OT.PointBins == currentBin);
            end
        end
    end
end