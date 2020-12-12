load('parms.mat')

parms.apo.cut(1) = 0.3; % fraction of vertical ascribed to each aponeurosis
parms.apo.cut(2) = 0.5; % fraction of vertical ascribed to each aponeurosis
parms.apo.frangi.FrangiScaleRange = [18 20];

parms.fas.cut = [.15 .2];
parms.fas.thetares =.5;
parms.fas.frangi.FrangiScaleRange = [1 2];
parms.fas.houghangles = 'manual';
parms.fas.npeaks = 5;

save('parms.mat','parms')