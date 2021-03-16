function[bethas, thickness] = correct_aponneuroses(deep_aponeurosis_vectors, super_aponeurosis_vectors, parms)
    
deep_aponeurosis_vectors_int = time_interpolate_aponeurosis(deep_aponeurosis_vectors,3);
super_aponeurosis_vectors_int = time_interpolate_aponeurosis(super_aponeurosis_vectors,3);

parms.apo.apox = round(linspace(parms.apo.apomargin, parms.m-parms.apo.apomargin, parms.apo.napo));

for k = 1:size(deep_aponeurosis_vectors_int,1)
    super_coef = polyfit(parms.apo.apox,super_aponeurosis_vectors_int(k,:),1);
    deep_coef = polyfit(parms.apo.apox,deep_aponeurosis_vectors_int(k,:),1);

    % evaluate thickness and fascicle length
    bethas(k,1) = -atan2d(super_coef(1),1);
    thickness(k,1) = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(bethas(k,1));
end
end