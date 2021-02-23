function[apo_simple, betha] = apo_func(apo_obj, parms)
%% Find the extremes on the object
% extract the white pixel locations
[apo_objy,apo_objx] = find(apo_obj);
apo_simple = nan(size(parms.apox));

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(apo_objx == parms.apox(i)) > 0
        apo_simple(i) = max(apo_objy(apo_objx == parms.apox(i)));
    end
end  

% Optional: betha from linear fit on object
p = polyfit(parms.apox(isfinite(apo_simple)),apo_simple(isfinite(apo_simple)),1);
betha = -atan2d(p(1),1);

end
