function[alpha, betha, thickness] = auto_ultrasound(data,parms)

[n,m] = size(data);

%% Step 1: Filtering
% aponeurosis
aponeurosis = FrangiFilter2D(double(data), parms.apo.frangi);
super_filt = bwpropfilt(imbinarize(aponeurosis(:,parms.apo.apox(1):parms.apo.apox(end))),'orientation', parms.apo.superrange);
deep_filt = bwpropfilt(imbinarize(aponeurosis(:,parms.apo.apox(1):parms.apo.apox(end))),'orientation', parms.apo.deeprange);

% fascicle
fascicle = FrangiFilter2D(double(data), parms.fas.frangi);

%% Step 2: Feature detection
% superficial aponeurosis
super_filt(round(parms.apo.supercut*n):end,:) = 0;  
[super_aponeurosis, betha] = apo_func(super_filt, parms.apo);

% deep aponeurosis
deep_filt(1:round(parms.apo.deepcut*n),:) = 0;  
deep_aponeurosis = n - apo_func(flip(deep_filt), parms.apo);

%% Step 2b: Fascicle angle detection
% plot regions
parms.fas.middle = round((mean(deep_aponeurosis,'omitnan') + mean(super_aponeurosis,'omitnan'))/2);

% Fascicle (Hough)
[alpha, fascicle_lines] = dohough(fascicle,parms.fas);

%% Step 3: Variables extraction
height = mean(deep_aponeurosis-super_aponeurosis,'omitnan');
thickness = height * cosd(betha);

%% Plot things
% Plot the fascicle region
c = parms.fas.cut;

if parms.show
   
    color = get(gca,'colororder');
    imshow(data,[]);

    % plot region of interest
    line('xdata',[round(m/2-n*c(1)) round(m/2+n*c(1)) round(m/2+n*c(1)) round(m/2-n*c(1)) round(m/2-n*c(1))], ...
         'ydata',[parms.fas.middle-(n*c(1)), parms.fas.middle-(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle-(n*c(1))] ...
        ,'linestyle','--', 'linewidth', 2, 'color', color(2,:))

    line('xdata', [parms.apo.apox(1) parms.apo.apox(end)] , 'ydata', n.*[parms.apo.supercut parms.apo.supercut],'linewidth',2, 'linestyle', '--', 'color', color(6,:))
    line('xdata', [parms.apo.apox(1) parms.apo.apox(end)] , 'ydata', n.*[parms.apo.deepcut parms.apo.deepcut],'linewidth',2, 'linestyle', '--', 'color', color(5,:))
        
    % plot identified aponeuroses and fascicle
    line('xdata',parms.apo.apox, 'ydata', deep_aponeurosis,'linewidth',3, 'color', color(5,:))
    line('xdata',parms.apo.apox, 'ydata', super_aponeurosis,'linewidth',3, 'color', color(6,:));
    line('xdata',[fascicle_lines(1,1) fascicle_lines(1,3)],'ydata',[fascicle_lines(1,2) fascicle_lines(1,4)],'LineWidth',3, 'color', color(2,:))
drawnow

end

%% Error messages
if isnan(betha)
    disp('Not able to find aponeuroses, try changing the parameters')
end
