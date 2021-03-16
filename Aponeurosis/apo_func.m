function[apo_simple] = apo_func(apo_obj, parms)

[apo_objy,apo_objx] = find(apo_obj);
apo_simple = nan(size(parms.apox));

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(apo_objx == parms.apox(i)) > 0
        apo_simple(i) = max(apo_objy(apo_objx == parms.apox(i)));
    end
end  

end
