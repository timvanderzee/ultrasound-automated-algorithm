function[apo_simple] = apo_func(aponeurosis, parms)

% This function finds vertical coordinates of the aponeurosis object
% given the filtered image(aponeurosis) and parameters (parms)

% Outputs:
    % apo_simple: vertical location of the pixels on the edge of the aponeurosis

% Inputs:
    % aponeurosis: filtered aponeurosis image (nxmx3)
    % parms: struct containing parameter values in its fields
    
% Tim van der Zee 2020-08-29

% define output
apo_simple = nan(size(parms.apox));

% cut sides
aponeurosis(:,1:parms.apox(1)) = 0;
aponeurosis(:,parms.apox(end):end) = 0;

% find the two longest objects
two_longest = bwpropfilt(aponeurosis, 'Majoraxislength',2);

%% Decision: if its NOT a close call, choose the longest, else, choose the deepest
props = regionprops(two_longest,'Majoraxislength');

% Check wheter it's a close call or not
if min(props.MajorAxisLength) < (parms.maxlengthratio * max(props.MajorAxisLength))
    apo_obj = bwareafilt(two_longest,1); % choose the longest
else
    
    % Identify two objects
    objects = bwconncomp(two_longest);
    
    % If there are indeed two objects
    if size(objects.PixelIdxList,2)>1
        % Evaluate centroids
        props = regionprops(two_longest,'Centroid');
        for i = 1:2
            Cy(i) = props(i).Centroid(2);
        end
        
        % Choose the biggest
        [~,minloc] = min(Cy);
        two_longest(objects.PixelIdxList{minloc}) = 0;
    end
    apo_obj = two_longest;
end


% Give up if too small
props = regionprops(apo_obj,'Majoraxislength');
if props.MajorAxisLength < parms.minlength
    return
end
    

%% Find the extremes on the object
% fill holes
apo_obj = imfill(apo_obj, 'holes');

% extract the white pixel locations
[apo_objy,apo_objx] = find(apo_obj);

maxapo = nan(size(parms.apox));
minapo = nan(size(parms.apox));

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(apo_objx == parms.apox(i)) > 0
        maxapo(i) = max(apo_objy(apo_objx == parms.apox(i)));
        minapo(i) = min(apo_objy(apo_objx == parms.apox(i)));
    end
end  

%% Fill gaps between extremes
for i = 1:length(parms.apox)
    if sum(apo_objx == parms.apox(i)) > 0
        % take a vertical slice through the aponeurosis
        aposlice = apo_obj(minapo(i):maxapo(i),parms.apox(i));
        
        % fill gaps if not too big
        if sum(aposlice) > (length(aposlice)-parms.fillgap)
            apo_obj(minapo(i):maxapo(i),parms.apox(i)) = 1;
        end
    end
end  

%% Boundary definition: choose the first black pixel from the lowest white pixel
[iapo_objy,iapo_objx] = find(~apo_obj); % inverse image

for i = 1:length(parms.apox)
    % if x-value exists for parms.apox value, choose the maximum
    if sum(iapo_objx == parms.apox(i)) > 0 && isfinite(maxapo(i))
        all_blackpixels = iapo_objy(iapo_objx == parms.apox(i));
        apo_simple(:,i) = min(all_blackpixels(all_blackpixels>minapo(i)));
    end
end  
end
