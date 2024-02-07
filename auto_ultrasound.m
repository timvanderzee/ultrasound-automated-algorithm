function[geofeatures, apovecs, parms] = auto_ultrasound(ultrasound_image, parms)

s = tic;

% determine size
[n,m,p] = size(ultrasound_image);
image_brightness = mean(ultrasound_image(:));

parms.apo.apox = round(linspace(parms.apo.apomargin, m-parms.apo.apomargin, parms.apo.napo));

% Extrapolate deep aponeurosis
delta_apo = mean(diff(parms.apo.apox));
apox_extrap = (parms.apo.apomargin-delta_apo*parms.apo.nextrap):delta_apo:(parms.apo.apomargin-delta_apo);

%% Step 1: Filtering
[fascicle, super_obj, deep_obj] = filter_usimage(ultrasound_image,parms);

%% Step 2: Feature detection
if strcmp(parms.apo.method,'Frangi')
    deep_aponeurosis_raw = n - (apo_func(flip(deep_obj), parms.apo));
    super_aponeurosis_raw = apo_func(super_obj, parms.apo);
    super_aponeurosis_vector = super_aponeurosis_raw - .5*parms.apo.sigma;
    deep_aponeurosis_vector = deep_aponeurosis_raw + .5*parms.apo.sigma;
else
    super_aponeurosis_vector = super_obj;
    deep_aponeurosis_vector = deep_obj;
end

% Optional: show image
if parms.show
    data_padded = [ones(n,round(m/2),p) ultrasound_image ones(n,round(m/2),p)];     % zero padding
    imshow(data_padded,'xdata',[-round(m/2) round(1.5*m)], 'ydata',[1 n]);
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
super_coef = fit_apo(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),parms.apo.super, parms.apo.super.order);
deep_coef = fit_apo(parms.apo.apox(isfinite(deep_aponeurosis_vector)),deep_aponeurosis_vector(isfinite(deep_aponeurosis_vector)),parms.apo.deep, parms.apo.deep.order);

% linear versions
super_coef_lin = fit_apo(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),parms.apo.super, 1);
deep_coef_lin = fit_apo(parms.apo.apox(isfinite(deep_aponeurosis_vector)),deep_aponeurosis_vector(isfinite(deep_aponeurosis_vector)),parms.apo.deep, 1);

% don't allow positive first coefficients
% if deep_coef(1) > 0, deep_coef = deep_coef_lin;
% end

% Optional: extrapolate. If extrapolation mode choose width location to minimize amount of
% extrapolation on each side
if parms.extrapolation
    
    Mx = round(m/2);
    My = mean([polyval(deep_coef_lin, Mx) polyval(super_coef_lin, Mx)]);
    
    fas_coef(1) = -tand(alpha);
    fas_coef(2) =  My - Mx * fas_coef(1);
    
    cost = @(x, super_coef_lin, deep_coef_lin, fas_coef) max([(Mx - (x-deep_coef_lin(2)) / (deep_coef_lin(1)-fas_coef(1))).^2  (Mx - (x-super_coef_lin(2)) / (super_coef_lin(1)-fas_coef(1))).^2]);
    
    fas_coef(2) = fminsearch(@(x) cost(x, super_coef_lin, deep_coef_lin, fas_coef), My - Mx * fas_coef(1));
    
%     parms.apo.x = round(fzero(@(x) polyval(deep_coef_lin(:)-fas_coef(:),x),0));

    parms.apo.x = (fas_coef(2) -deep_coef_lin(2)) / (deep_coef_lin(1)-fas_coef(1));
    
else
    fas_coef = [];
end

% extract variables
fat_thickness = round(mean(super_aponeurosis_vector,'omitnan'));
betha = -atan2d(super_coef_lin(1),1);
gamma = -atan2d(deep_coef_lin(1),1);
muscle_thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = muscle_thickness ./ sind(alpha-betha);

extrapolated_fraction = (faslen - m/cosd(alpha)) / faslen;

%% Plot figure
if parms.show
    make_us_figure(ultrasound_image, deep_aponeurosis_vector, super_aponeurosis_vector, alpha, super_coef, deep_coef, parms)
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
geofeatures.phi = alpha-betha;
geofeatures.fat_thickness = fat_thickness;
geofeatures.ws = ws;
geofeatures.brightness = image_brightness;
geofeatures.extrapolated_fraction = extrapolated_fraction;
geofeatures.analysis_duration = toc(s);

geofeatures.super_coef = super_coef;
geofeatures.deep_coef = deep_coef;
geofeatures.fas_coef = fas_coef;

apovecs.super_aponeurosis_vector = super_aponeurosis_vector;
apovecs.deep_aponeurosis_vector = deep_aponeurosis_vector;


end
