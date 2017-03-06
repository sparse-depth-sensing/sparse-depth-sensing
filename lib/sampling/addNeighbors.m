function samples = addNeighbors(corners, height, width)
%ADDNEIGHBORS include all 4 neighbors (up, down, left, right) as samples

samples = [];

for i = 1:length(corners)
    [I,J] = ind2sub([height, width], corners(i));

    for h = -1:1
        for k = -1:1
            if I+h>=1 && J+k>=1 && I+h<=height && J+k<=width && ( abs(h)+abs(k)<2 )
                newSample = sub2ind([height width], I+h, J+k);
                
                % add the neighbor, if it is not already in the sample set
                if ismember(newSample, samples) == 0 
                    samples = [samples; newSample];
                end
            end
        end
    end
end