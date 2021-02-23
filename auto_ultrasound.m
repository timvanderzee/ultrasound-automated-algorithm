function[alpha, betha, thickness, parms] = auto_ultrasound(data,parms)

[n,m] = size(data);

%% Step 1: Filtering
[fascicle, super_obj, deep_obj] = filter_usimage(data,parms);

%% Step 2: Feature detection
[super_aponeurosis_raw, betha] = apo_func(super_obj, parms.apo.super);
deep_aponeurosis_raw = n - (apo_func(flip(deep_obj), parms.apo.deep));

% Correct for width of Gaussian kernel
super_aponeurosis_vector = super_aponeurosis_raw - parms.apo.sigma;
deep_aponeurosis_vector = deep_aponeurosis_raw + parms.apo.sigma;

%% Step 2b: Fascicle angle detection
% Determine fascicle region using detected aponeuroses
parms.fas.middle = round((mean(deep_aponeurosis_vector,'omitnan') + mean(super_aponeurosis_vector,'omitnan'))/2);
parms.fas.cut = round((mean(deep_aponeurosis_vector,'omitnan') - mean(super_aponeurosis_vector,'omitnan'))/2);

% Fascicle (Hough)
alpha = dohough(fascicle,parms.fas);

%% Step 3: Variables extraction
height = mean(deep_aponeurosis_vector - super_aponeurosis_vector,'omitnan');
thickness = height * cosd(betha);

%% Plot things
if parms.show
   
    imshow(data,[]);
    
    line('xdata',parms.apo.deep.apox, 'ydata', deep_aponeurosis_vector,'linewidth',3, 'color', 'Blue')
    line('xdata',parms.apo.super.apox, 'ydata', super_aponeurosis_vector,'linewidth',3, 'color', 'Blue');

    for u = 1:round(n/60)-1
        line('xdata', [1 m], 'ydata', [n round(n-tand(alpha)*m)]-(u-1)*60,'linewidth',1','linestyle','-', 'color', 'Red');
    end

    drawnow
end

%% Error messages
if isnan(parms.fas.middle)
    parms.fas.middle = n/2;
    disp('Warning: undetected aponeurosis');
end
if isnan(alpha)
    disp('Issue with detecting fascicles')
end
if isnan(betha)
    disp('Not able to find aponeuroses, try changing the parameters')
end

end
