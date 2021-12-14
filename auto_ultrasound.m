function[geofeatures, apovecs, parms] = auto_ultrasound(ultrasound_image, parms)

% determine size
[n,m,p] = size(ultrasound_image);

parms.apo.apox = round(linspace(parms.apo.apomargin, m-parms.apo.apomargin, parms.apo.napo));

% Extrapolate deep aponeurosis
delta_apo = mean(diff(parms.apo.apox));
apox_extrap = (parms.apo.apomargin-delta_apo*parms.apo.nextrap):delta_apo:(parms.apo.apomargin-delta_apo);

%% Step 1: Filtering
[fascicle, super_obj, deep_obj] = filter_usimage(ultrasound_image,parms);

%% Step 2: Feature detection
deep_aponeurosis_raw = n - (apo_func(flip(deep_obj), parms.apo));
super_aponeurosis_raw = apo_func(super_obj, parms.apo);

% Correct for width of Gaussian kernel
super_aponeurosis_vector = super_aponeurosis_raw - .5*parms.apo.sigma;
deep_aponeurosis_vector = deep_aponeurosis_raw + .5*parms.apo.sigma;

% Optional: show image
if parms.show
    data_padded = [ones(n,m,p) ultrasound_image ones(n,m,p)];     % zero padding
    imshow(data_padded,'xdata',[-m 2*m], 'ydata',[1 n]);
end
%% Step 2b: Fascicle angle detection
% new step: ellipse mask for fascicle
if isfield(parms.fas, 'Emask') && numel(parms.fas.Emask) ~= numel(fascicle)
    parms.fas = rmfield(parms.fas, 'Emask');
end
if ~isfield(parms.fas,'Emask') || parms.fas.redo_ROI
    [parms.fas.Emask, parms.fas.Emask_radius] = get_fasMask(fascicle, super_aponeurosis_vector, deep_aponeurosis_vector, parms);
end

% Mask
fascicle_masked = fascicle .* parms.fas.Emask;

% Hough transform
[alphas,ws] = dohough(fascicle_masked, parms.fas);
alpha = weightedMedian(alphas,ws);

%% Step 3: Variables extraction
% Fit through vectors
super_coef = fit_apo(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),parms.apo.super);
deep_coef = fit_apo(parms.apo.apox(isfinite(deep_aponeurosis_vector)),deep_aponeurosis_vector(isfinite(deep_aponeurosis_vector)),parms.apo.deep);

parms.apo.super.order = 1; % force 1st order, otherwise betha is ill-defined
super_coef_lin = fit_apo(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),parms.apo.super);

% Optional: extrapolate. If extrapolation mode choose width location to minimize amount of
% extrapolation on each side
if parms.extrapolation
    
    Mx = round(m/2);
    My = mean([polyval(deep_coef, Mx) polyval(super_coef, Mx)]);
    
    fas_coef(1) = -tand(alpha);
    fas_coef(2) =  My - Mx * fas_coef(1);
    
    parms.apo.x = fzero(@(x) polyval(deep_coef(:)-fas_coef(:),x),0);
    
end

% extract variables
fat_thickness = round(mean(super_aponeurosis_vector,'omitnan'));
betha = -atan2d(super_coef_lin(1),1);
gamma = -atan2d(deep_coef(1),1);
muscle_thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = muscle_thickness ./ sind(alpha-betha);

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
geofeatures.gamma = gamma;
geofeatures.betha = betha;
geofeatures.thickness = muscle_thickness;
geofeatures.faslen = faslen;
geofeatures.alpha = alpha;
geofeatures.ws = ws;

apovecs.super_aponeurosis_vector = super_aponeurosis_vector;
apovecs.deep_aponeurosis_vector = deep_aponeurosis_vector;


end
