function[apo_simple, betha] = apo_func(apo_obj, parms)
[n,m] = size(apo_obj);
apox = parms.apomargin:parms.apospacing:(m-parms.apomargin);


%% Find the extremes on the object
% extract the white pixel locations

[apo_objy,apo_objx] = find(apo_obj);
apo_simple = nan(size(apox));



for i = 1:length(apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(apo_objx == apox(i)) > 0
        apo_simple(i) = max(apo_objy(apo_objx == apox(i)));
    end
end  


% Optional: betha from linear fit on object
p = polyfit(apox(isfinite(apo_simple)),apo_simple(isfinite(apo_simple)),1);
betha = -atan2d(p(1),1);

end
