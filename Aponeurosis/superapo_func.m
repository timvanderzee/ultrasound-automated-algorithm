function[super_simple] = superapo_func(aponeurosis, parms)

% This function finds vertical coordinates of the superficial aponeurosis object
% given the filtered image(aponeurosis) and parameters (parms)

% Outputs:
    % super_simple: vertical location of the deepest pixels on the superficial aponeurosis

% Inputs:
    % aponeurosis: filtered aponeurosis image (nxmx3)
    % parms: struct containing parameter values in its fields
    
% Tim van der Zee 2020-08-29

% define output
super_simple = nan(size(parms.apox));

% determine size
[n,~,~] = size(aponeurosis);

% threshold
apo_thres = imbinarize(aponeurosis);

% cut edges
c = parms.frangi.FrangiScaleRange(2);
apo_thres(1:c,:) = 0;
apo_thres((end-c):end,:) = 0;

apo_thres(:,1:parms.apox(1)) = 0;
apo_thres(:,parms.apox(end):end) = 0;

% select region
apo_thres(round(parms.cut(1)*n):end,:) = 0;  

% filter for angles
apo_super = bwpropfilt(apo_thres,'orientation', parms.superrange);

% find the two longest objects
two_longest = bwpropfilt(apo_super, 'Majoraxislength',2);

%% Decision: if its NOT a close call, choose the longest (else, implicitly choose the deepest)
props = regionprops(two_longest,'Majoraxislength');

if min(props.MajorAxisLength) < (parms.maxlengthratio * max(props.MajorAxisLength))
    super_obj = bwareafilt(two_longest,1); % choose the longest
else
    
    objects = bwconncomp(two_longest);
    
    % If there are indeed two objects
    if size(objects.PixelIdxList,2)>1
        props = regionprops(two_longest,'Centroid');
    
        for i = 1:2
            Cy(i) = props(i).Centroid(2);
        end
        
        [~,minloc] = min(Cy);
        two_longest(objects.PixelIdxList{minloc}) = 0;
    end
    super_obj = two_longest;
end
    

%% Find the most deep and superficial points on the object
% fill holes
super_obj = imfill(super_obj, 'holes');

% extract the white pixel locations
[super_objy,super_objx] = find(super_obj);

deepsupe = nan(size(parms.apox)); % deepest pixel in deep object
supesupe = nan(size(parms.apox)); % most superficial pixel in deep object

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(super_objx == parms.apox(i)) > 0
        deepsupe(i) = max(super_objy(super_objx == parms.apox(i)));
        supesupe(i) = min(super_objy(super_objx == parms.apox(i)));
    end
end  

%% Fill gaps between deepdeep and superdeep
for i = 1:length(parms.apox)
    if sum(super_objx == parms.apox(i)) > 0
        % take a vertical slice through the aponeurosis
        aposlice = super_obj(supesupe(i):deepsupe(i),parms.apox(i));
        
        % fill gaps if not too big
        if sum(aposlice) > (length(aposlice)-parms.fillgap)
            super_obj(supesupe(i):deepsupe(i),parms.apox(i)) = 1;
        end
    end
end  

%% Boundary definition: choose the first black pixel from the lowest white pixel
% inverse image
[isupe_objy,isupe_objx] = find(~super_obj);
for i = 1:length(parms.apox)
    % if x-value exists for parms.apox value, choose the maximum
    if sum(isupe_objx == parms.apox(i)) > 0 && isfinite(deepsupe(i))
        ideep_objy_selec = isupe_objy(isupe_objx == parms.apox(i));
        super_simple(:,i) = min(ideep_objy_selec(ideep_objy_selec>supesupe(i)));
    end
end  
end
