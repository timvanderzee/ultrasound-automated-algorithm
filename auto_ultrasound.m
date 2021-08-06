function[geofeatures, apovecs] = auto_ultrasound(ultrasound_image,parms)

[n,m,p] = size(ultrasound_image);

parms.apo.apox = round(linspace(parms.apo.apomargin, m-parms.apo.apomargin, parms.apo.napo));

%% Step 1: Filtering
[fascicle, super_obj, deep_obj] = filter_usimage(ultrasound_image,parms);

%% Step 2: Feature detection
deep_aponeurosis_raw = n - (apo_func(flip(deep_obj), parms.apo));
super_aponeurosis_raw = apo_func(super_obj, parms.apo);

% Correct for width of Gaussian kernel
super_aponeurosis_vector = super_aponeurosis_raw - .5*parms.apo.sigma;
deep_aponeurosis_vector = deep_aponeurosis_raw + .5*parms.apo.sigma;

% Extrapolate deep aponeurosis
delta_apo = mean(diff(parms.apo.apox));
apox_extrap = (parms.apo.apomargin-delta_apo*parms.apo.nextrap):delta_apo:(parms.apo.apomargin-delta_apo);

%% Step 2b: Fascicle angle detection
% Determine fascicle region using detected aponeuroses
fat_thickness = round(mean(super_aponeurosis_vector,'omitnan'));

if isfinite(mean(deep_aponeurosis_vector,'omitnan')) && isfinite(mean(super_aponeurosis_vector,'omitnan'))
    fascut = fascicle(fat_thickness:round(mean(deep_aponeurosis_vector,'omitnan')),:);
else
    fascut = fascicle;
    disp('Warning: no aponeurosis object');
end

if parms.show
    % zero padding
    data_padded = [ones(n,m,p) ultrasound_image ones(n,m,p)];
    imshow(data_padded,'xdata',[-m 2*m], 'ydata',[1 n]);
end

% Fascicle (Hough)
[alphas,ws] = dohough(fascut,fat_thickness, parms.fas);
alpha = weightedMedian(alphas,ws);

%% Step 3: Variables extraction
% Fit through vectors
super_coef = fit_apo(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),parms.apo.super);
deep_coef = fit_apo(parms.apo.apox(isfinite(deep_aponeurosis_vector)),deep_aponeurosis_vector(isfinite(deep_aponeurosis_vector)),parms.apo.deep);

parms.apo.super.order = 1; % force 1st order, otherwise betha is ill-defined
super_coef_lin = fit_apo(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),parms.apo.super);
betha = -atan2d(super_coef_lin(1),1);

% if extrapolation mode choose width location to minimize amount of
% extrapolation on each side
if parms.extrapolation
    
    Mx = round(m/2);
    My = mean([polyval(deep_coef, Mx) polyval(super_coef, Mx)]);
    
    fas_coef(1) = -tand(alpha);
    fas_coef(2) =  My - Mx * fas_coef(1);
    
    parms.apo.x = fzero(@(x) polyval(deep_coef(:)-fas_coef(:),x),0);
    
end

% evaluate thickness and fascicle length
thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = thickness ./ sind(alpha-betha);


%% Plot figure
if parms.show
    
    make_us_figure(ultrasound_image, deep_aponeurosis_vector, super_aponeurosis_vector, alpha, super_coef, deep_coef, parms)
   
end
    %% Plot fascicle length and thickness vs. longitudinal position
if parms.show2
    % thickness
    figure
    plot((apox_extrap - parms.apo.apomargin)/delta_apo, thickness_extrap/delta_apo,'ko','markersize',10,'markerfacecolor',[1 1 1]); hold on
    plot((parms.apo.apox(1:end-parms.apo.nexcl) - parms.apo.apomargin)/delta_apo, thicknessvec_deep(1:end-parms.apo.nexcl)/delta_apo, 'ko','markersize',10,'markerfacecolor',[0 0 0])
    plot((parms.apo.apox(end-parms.apo.nexcl+1:end) - parms.apo.apomargin)/delta_apo, thicknessvec_deep(end-parms.apo.nexcl+1:end)/delta_apo, 'ko','markersize',10,'markerfacecolor',[.5 .5 .5])

    line('xdata',-parms.apo.nextrap:1:(parms.apo.napo-1), 'ydata', [thickness_extrap thicknessvec_int]/delta_apo)

    ylim([4 6])
    xlim([-(parms.apo.nextrap+1) parms.apo.napo])
    set(gca,'xtick', -(parms.apo.nextrap+1):1:parms.apo.napo)
end

%% Error messages
if isnan(alpha)
    disp('Issue with detecting fascicles')
end
if isnan(betha)
    disp('Not able to find aponeuroses, try changing the parameters')
end

%% Assign output
geofeatures.alphas = alphas;
geofeatures.betha = betha;
geofeatures.thickness = thickness;
geofeatures.faslen = faslen;
geofeatures.alpha = alpha;
geofeatures.ws = ws;

apovecs.super_aponeurosis_vector = super_aponeurosis_vector;
apovecs.deep_aponeurosis_vector = deep_aponeurosis_vector;


end
