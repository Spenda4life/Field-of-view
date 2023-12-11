function hit = fastRay(OT, orig, dir, vertices, faces)
    binPoints = false(size(OT.Points,1),1);
    stack = zeros(OT.BinCount, 1);
    stack(1) = 1;
    stackEnd = 1;
    while stackEnd ~= 0
        currentBin = stack(stackEnd);
        stackEnd = stackEnd - 1;
        [intersect ,~] = rayBoxIntersection(orig, dir,...
            OT.BinBoundaries(currentBin, 1:3),...
            OT.BinBoundaries(currentBin, 4:6));
        if intersect
            childBinIndices = find(OT.BinParents == currentBin);
            if any(childBinIndices)
                stackEnd = stackEnd + 1;
                stack(stackEnd) = childBinIndices(1);
                for i = 2:length(childBinIndices)
                    stackEnd = stackEnd + 1;
                    stack(stackEnd) = childBinIndices(i);
                end
            else
                binPoints = binPoints | (OT.PointBins == currentBin);
            end
        end
    end

    if any(binPoints) 
        [intersections, ~, ~, ~, ~] = ...
            TriangleRayIntersection(orig, dir,...
            vertices(faces(binPoints,1),:),...
            vertices(faces(binPoints,2),:),...
            vertices(faces(binPoints,3),:));
        hit = (sum(intersections) > 0);
    else
        hit = false;
    end
end