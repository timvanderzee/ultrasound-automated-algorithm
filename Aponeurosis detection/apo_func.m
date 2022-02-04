function[apo_simple] = apo_func(apo_obj, parms)

% [apo_objy,apo_objx] = find(apo_obj);
% apo_simple = nan(size(parms.apox));

% for i = 1:length(parms.apox)
%     % x-value exists for parms.apox value, choose the maximum
%     if sum(apo_objx == parms.apox(i)) > 0
%         apo_simple(i) = max(apo_objy(apo_objx == parms.apox(i)));
%     end
% end  
%% Find the most superficial and the deepest points on the object
% fill holes
apo_obj = imfill(apo_obj, 'holes');

% extract the white pixel locations
[objy,objx] = find(apo_obj);

deep_edge = nan(size(parms.apox)); % deepest pixel in deep object
super_edge = nan(size(parms.apox)); % most superficial pixel in deep object

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(objx == parms.apox(i)) > 0
        deep_edge(i) = max(objy(objx == parms.apox(i)));
        super_edge(i) = min(objy(objx == parms.apox(i)));
    end
end  

%% Fill gaps between deepdeep and superdeep
for i = 1:length(parms.apox)
    if sum(objx == parms.apox(i)) > 0
        % take a vertical slice through the aponeurosis
        aposlice = apo_obj(super_edge(i):deep_edge(i),parms.apox(i));
        
        % fill gaps if not too big
        if sum(aposlice) > (length(aposlice)-parms.fillgap)
            apo_obj(super_edge(i):deep_edge(i),parms.apox(i)) = 1;
        end
    end
end  

%% Boundary definition: choose the first black pixel from the lowest white pixel
% inverse image
[ideep_objy,ideep_objx] = find(~apo_obj);

apo_simple = nan(size(parms.apox));

for i = 1:length(parms.apox)
    % if x-value exists for parms.apox value, choose the maximum
    if sum(ideep_objx == parms.apox(i)) > 0 && isfinite(deep_edge(i))
        ideep_objy_selec = ideep_objy(ideep_objx == parms.apox(i));
        apo_simple(:,i) = min(ideep_objy_selec(ideep_objy_selec > super_edge(i)));
    end
end  

% keyboard
% figure
% imshow(apo_obj); hold on
% plot(parms.apox, deep_edge, 'r.')
% plot(parms.apox, super_edge, 'b.')
% 
% plot(parms.apox, apo_simple,'b')
% keyboard
end
