function [X] = get_apo_props(object)

obj_props = regionprops('struct',object,'MajorAxisLength','MinorAxisLength','Area','Centroid');

rMaAL = obj_props.MajorAxisLength;
rMiAL = obj_props.MinorAxisLength;
rArea = obj_props.Area;
rCent = obj_props.Centroid(2);

X = [rMaAL(:) rMiAL(:) rArea(:) rCent(:)];

end