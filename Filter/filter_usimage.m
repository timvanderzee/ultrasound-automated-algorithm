function[fascicle, super_filt, deep_filt] = filter_usimage(data,parms)

[n,m] = size(data);

% aponeurosis
aponeurosis = FrangiFilter2D(double(data), parms.apo.frangi);

aponeurosis(:,1:parms.apo.apox(1)) = 0;
aponeurosis(:,parms.apo.apox(end):end) = 0;

deep_apo = aponeurosis; super_apo = aponeurosis;
deep_apo(1:round(parms.apo.deepcut(1)*n),:) = 0;  
deep_apo((round(parms.apo.deepcut(2)*n):end),:) = 0;  

super_apo(1:round(parms.apo.supercut(1)*n),:) = 0;  
super_apo(round(parms.apo.supercut(2)*n):end,:) = 0;  

super_filt = bwareaopen(imbinarize(super_apo), 200);
deep_filt = bwareaopen(imbinarize(deep_apo,'adaptive','sensitivity', .3),200);


% fascicle
fascicle = FrangiFilter2D(double(data), parms.fas.frangi);

end