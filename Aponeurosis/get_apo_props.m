function [X] = get_apo_props(object)

o = regionprops('struct',object,'MajorAxisLength','MinorAxisLength','Area','Centroid','Orientation','Eccentricity','ConvexArea','Circularity','EquivDiameter','Solidity','Extent','Perimeter');
c = struct2cell(o);

for i = 1:length(c)
    
    if size(c{i},2)<2
        X(i) = c{i};
    else
        X(i) = c{i}(2);
    end
end

end