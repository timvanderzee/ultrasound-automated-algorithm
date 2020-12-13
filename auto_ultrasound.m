function[alpha, betha, thickness] = auto_ultrasound(data,parms)

[n,m,p] = size(data);

%% Step 1: Frangi filtering
% aponeurosis
aponeurosis = FrangiFilter2D(double(data), parms.apo.frangi);

% fascicle
fascicle = FrangiFilter2D(double(data), parms.fas.frangi);

%% Step 2: Feature detection
% Aponeurosis
deep_aponeurosis = deepapo_func(aponeurosis, parms.apo);
super_aponeurosis = superapo_func(aponeurosis, parms.apo);

%% Step 2b: 
% plot regions
parms.fas.middle = round((mean(deep_aponeurosis,'omitnan') + mean(super_aponeurosis,'omitnan'))/2);

% Fascicle (Hough)
[alpha, fascicle_lines] = dohough(fascicle,parms.fas);

%% Step 3: Variables extraction
p = polyfit(parms.apo.apox(isfinite(super_aponeurosis)), super_aponeurosis(isfinite(super_aponeurosis)),1);
betha = -atan2d(p(1),1); 

height = mean(deep_aponeurosis-super_aponeurosis,'omitnan');
thickness = height * cosd(betha);

%% Plot things
% Plot the fascicle region
c = parms.fas.cut;

if parms.show
    
    figure(1)
    color = get(gca,'colororder');
    imshow(data,[]);

    % plot region of interest
    line('xdata',[m*c(2) m*(1-c(2)) m*(1-c(2)) m*c(2) m*c(2)], ...
         'ydata',[parms.fas.middle-(n*c(1)), parms.fas.middle-(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle-(n*c(1))] ...
        ,'linestyle','--', 'linewidth', 2, 'color', color(2,:))

    line('xdata', [parms.apo.apox(1) parms.apo.apox(end)] , 'ydata', n.*[parms.apo.cut(1) parms.apo.cut(1)],'linewidth',2, 'linestyle', '--', 'color', color(6,:))
    line('xdata', [parms.apo.apox(1) parms.apo.apox(end)] , 'ydata', n.*[(1-parms.apo.cut(2)) (1-parms.apo.cut(2))],'linewidth',2, 'linestyle', '--', 'color', color(5,:))
        
    % plot identified aponeuroses and fascicle
    line('xdata',parms.apo.apox, 'ydata', deep_aponeurosis,'linewidth',3, 'color', color(5,:))
    line('xdata',parms.apo.apox, 'ydata', super_aponeurosis,'linewidth',3, 'color', color(6,:));
    line('xdata',[fascicle_lines(1,1) fascicle_lines(1,3)],'ydata',[fascicle_lines(1,2) fascicle_lines(1,4)],'LineWidth',3, 'color', color(2,:))
drawnow

end
