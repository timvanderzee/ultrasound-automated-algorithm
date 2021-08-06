function[apo_simple] = apo_func(apo_obj, parms)

apo_simple = nan(size(parms.apox));

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
