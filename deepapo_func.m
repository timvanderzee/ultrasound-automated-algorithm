function[deep_simple] = deepapo_func(aponeurosis, parms)

% This function finds vertical coordinates of the deep aponeurosis object
% given the filtered image(aponeurosis) and parameters (parms)

% Outputs:
    % deep_simple: vertical location of the most superficial pixels on the deep aponeurosis

% Inputs:
    % aponeurosis: filtered aponeurosis image (nxmx3)
    % parms: struct containing parameter values in its fields
    
% Tim van der Zee 2020-08-29

% define output
deep_simple = nan(size(parms.apox));

% determine size
[n,~,~] = size(aponeurosis);

% threshold image
apo_thres = imbinarize(aponeurosis);

% cut edges
c = parms.frangi.FrangiScaleRange(2)*2;
apo_thres(1:c,:) = 0;
apo_thres(:,1:c) = 0;
apo_thres((end-c):end,:) = 0;
apo_thres(:,(end-c):end) = 0;

% select region
apo_thres(1:round((1-parms.cut(2))*n),:) = 0;

% filter for angles
apo_deep = bwpropfilt(apo_thres,'orientation', parms.deeprange);

% find the two longest objects
objects = bwconncomp(apo_deep);

if objects.NumObjects>1
    two_longest = bwpropfilt(apo_deep,'MajorAxisLength',2);
else
    two_longest = apo_deep;
end

%% if 2 long objects, choose the most superficial   
props = regionprops(two_longest,'MajorAxisLength','Extrema');
objects = bwconncomp(two_longest);

if ~isempty(props) && objects.NumObjects>1
    if  min(props.MajorAxisLength) > (parms.maxlengthratio * max(props.MajorAxisLength))

        % location of most superficial extrema
        miny = nan(size(props));
        for i = 1:size(props,2)
            miny(i) = min(props(i).Extrema(:,2));
        end
        
        % find out which object is deepest and delete it
        [~,maxloc] = max(miny);
        two_longest(objects.PixelIdxList{maxloc}) = 0;
    end
end

% select the longest
deep_obj = bwareafilt(two_longest, 1);     

%% Decide to proceed or give up if
props = regionprops(deep_obj,'MajorAxisLength');

if props.MajorAxisLength < parms.minlength
    return
end

%% Find the most superficial and the deepest points on the object
% fill holes
deep_obj = imfill(deep_obj, 'holes');

% extract the white pixel locations
[deep_objy,deep_objx] = find(deep_obj);

deepdeep = nan(size(parms.apox)); % deepest pixel in deep object
supedeep = nan(size(parms.apox)); % most superficial pixel in deep object

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(deep_objx == parms.apox(i)) > 0
        deepdeep(i) = max(deep_objy(deep_objx == parms.apox(i)));
        supedeep(i) = min(deep_objy(deep_objx == parms.apox(i)));
    end
end  

%% Fill gaps between deepdeep and superdeep
for i = 1:length(parms.apox)
    if sum(deep_objx == parms.apox(i)) > 0
        % take a vertical slice through the aponeurosis
        aposlice = deep_obj(supedeep(i):deepdeep(i),parms.apox(i));
        
        % fill gaps if not too big
        if sum(aposlice) > (length(aposlice)-parms.fillgap)
            deep_obj(supedeep(i):deepdeep(i),parms.apox(i)) = 1;
        end
    end
end  

%% Boundary definition: choose the first black pixel from the lowest white pixel
% inverse image
[ideep_objy,ideep_objx] = find(~deep_obj);
for i = 1:length(parms.apox)
    % if x-value exists for parms.apox value, choose the maximum
    if sum(ideep_objx == parms.apox(i)) > 0 && isfinite(deepdeep(i))
        ideep_objy_selec = ideep_objy(ideep_objx == parms.apox(i));
        deep_simple(:,i) = max(ideep_objy_selec(ideep_objy_selec<deepdeep(i)));
    end
end  
end

