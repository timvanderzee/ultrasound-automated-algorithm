function[alpha, betha, thickness, parms] = auto_ultrasound(data,parms)

% define outputs
alpha = nan(3,1);
betha = nan(1,1);
thickness = nan(1,1);

[n,m] = size(data);

%% Step 1: Filtering
[fascicle, super_filt, deep_filt] = filter_usimage(data,parms);

%% Step 2: Feature detection
[deep_obj, parms.apo.SVM.deep] = get_apo_obj(deep_filt, parms.apo.SVM.deep);
[super_obj, parms.apo.SVM.super] = get_apo_obj(super_filt, parms.apo.SVM.super);

[super_aponeurosis, betha] = apo_func(super_obj, parms.apo);
deep_aponeurosis = n - apo_func(flip(deep_obj), parms.apo);

%% Step 2b: Fascicle angle detection
% plot regions
parms.fas.middle = round((mean(deep_aponeurosis,'omitnan') + mean(super_aponeurosis,'omitnan'))/2);

if isnan(parms.fas.middle)
    parms.fas.middle = n/2;
    disp('Warning: undetected aponeurosis');
end

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
    line('xdata',[1 m m 1 1], ...
         'ydata',[parms.fas.middle-(n*c(1)), parms.fas.middle-(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle+(n*c(1)) parms.fas.middle-(n*c(1))] ...
        ,'linestyle','--', 'linewidth', 2, 'color', color(2,:))

    for i = 1:2
        line('xdata', [parms.apo.apox(1) parms.apo.apox(end)] , 'ydata', n.*[parms.apo.supercut(i) parms.apo.supercut(i)],'linewidth',2, 'linestyle', '--', 'color', color(6,:))
        line('xdata', [parms.apo.apox(1) parms.apo.apox(end)] , 'ydata', n.*[parms.apo.deepcut(i) parms.apo.deepcut(i)],'linewidth',2, 'linestyle', '--', 'color', color(5,:))
    end
    
    % plot identified aponeuroses and fascicle
    line('xdata',parms.apo.apox, 'ydata', deep_aponeurosis,'linewidth',3, 'color', color(5,:))
    line('xdata',parms.apo.apox, 'ydata', super_aponeurosis,'linewidth',3, 'color', color(6,:));
    
    for s = 1:3
    line('xdata',[fascicle_lines(1,1,s) fascicle_lines(1,3,s)],'ydata',[fascicle_lines(1,2,s) fascicle_lines(1,4,s)],'LineWidth',3, 'color', color(2,:))
    end
drawnow

end

%% Error messages
if isnan(betha)
    disp('Not able to find aponeuroses, try changing the parameters')
end

end
