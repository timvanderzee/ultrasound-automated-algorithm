function[alpha, betha, thickness, parms] = auto_ultrasound(data,parms)

[n,m] = size(data);

%% Step 1: Filtering
[fascicle, super_filt, deep_filt] = filter_usimage(data,parms);

%% Step 2: Feature detection
deep_obj = get_apo_obj(deep_filt, parms.apo.deep.SVM);
super_obj = get_apo_obj(super_filt, parms.apo.super.SVM);

[super_aponeurosis] = apo_func(super_obj, parms.apo.super);
deep_aponeurosis = n - apo_func(flip(deep_obj), parms.apo.deep);

% alternative betha
p = polyfit(parms.apo.super.apox(isfinite(super_aponeurosis)),super_aponeurosis(isfinite(super_aponeurosis)),1);
betha = -atan2d(p(1),1);

%% Step 2b: Fascicle angle detection
parms.fas.middle = round((mean(deep_aponeurosis,'omitnan') + mean(super_aponeurosis,'omitnan'))/2);

if isnan(parms.fas.middle)
    parms.fas.middle = n/2;
    disp('Warning: undetected aponeurosis');
end

% Fascicle (Hough)
[alpha, fascicle_lines] = dohough(fascicle,parms.fas);

if isnan(alpha)
    disp('Issue with detecting fascicles')
end

%% Step 3: Variables extraction
height = mean(deep_aponeurosis-super_aponeurosis,'omitnan');
thickness = height * cosd(betha);

%% Plot things
if parms.show
    %% Plotting 
    figure(1);
    imshow(data,[]);
    line('xdata',parms.apo.deep.apox, 'ydata', deep_aponeurosis,'linewidth',3, 'color', 'Blue')
    line('xdata',parms.apo.super.apox, 'ydata', super_aponeurosis,'linewidth',3, 'color', 'Blue');

    for u = 1:round(n/30)-1
        line('xdata', [1 m], 'ydata', [n round(n-tand(alpha)*m)]-(u-1)*30,'linewidth',1','linestyle','--', 'color', 'Red');
    end

        for s = 1:3
            line('xdata',[fascicle_lines(1,1,s) fascicle_lines(1,3,s)],'ydata',[fascicle_lines(1,2,s) fascicle_lines(1,4,s)],'LineWidth',3, 'color', 'Red')
        end
    drawnow
end

%% Error messages
if isnan(betha)
    disp('Not able to find aponeuroses, try changing the parameters')
end

end
