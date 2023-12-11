function hit = castRay(OT, orig, dir, vertices, faces)

    binPoints = false(size(OT.Points,1),1);
    traverseTree(1);

    function traverseTree(currentBin)
	
        [intersect ,~] = rayBoxIntersection(orig, dir,...
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