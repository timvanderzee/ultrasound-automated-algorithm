function[apo_vec] = apo_func(apo_obj, parms)

[apo_objy,apo_objx] = find(apo_obj);
apo_simple = nan(size(parms.apox));

for i = 1:length(parms.apox)
    % x-value exists for parms.apox value, choose the maximum
    if sum(apo_objx == parms.apox(i)) > 0
        apo_simple(i) = max(apo_objy(apo_objx == parms.apox(i)));
    end
end  

if sum(isfinite(apo_simple))>1
    apo_vec = interp1(parms.apox(isfinite(apo_simple)), apo_simple(isfinite(apo_simple)), parms.apox, 'linear', 'extrap');
else
    apo_vec = nan(size(parms.apox));
    disp('Warning: only 1 point on aponeurosis');
end

end
