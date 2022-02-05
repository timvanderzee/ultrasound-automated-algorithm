function[geofeatures, apovecs] = post_hoc_correction(geofeatures, apovecs, parms, threshold)

if strcmp(parms.step6,'Y')
    for i = 1:length(geofeatures)
        super_apo(i,:) = apovecs(i).super_aponeurosis_vector;
        deep_apo(i,:) = apovecs(i).deep_aponeurosis_vector;
        alpha(i,:) = geofeatures(i).alpha;
        brightness(i,:) = geofeatures(i).brightness;
    end

    max_brighness = double(max(parms.image_sequence(:)));
    brel = brightness/max_brighness;

    id = brel < threshold;

    %% replace with nan
    % make copy
    alpha_old = alpha;
    super_apo_old = super_apo;
    deep_apo_old = deep_apo;

    % remove
    alpha(id,:) = nan;
    super_apo(id,:) = nan;
    deep_apo(id,:) = nan;

    %% interpolate
    [m,n] = size(super_apo);

    super_apo_int = nan(size(super_apo));
    deep_apo_int = nan(size(super_apo));

    for i = 1:n
        x = 1:m;
        super_apo_int(:,i) = interp1(x(~id), super_apo(~id,i), x,'linear','extrap');    
        deep_apo_int(:,i) = interp1(x(~id), deep_apo(~id,i), x,'linear','extrap');    
        alpha_int = interp1(x(~id), alpha(~id,:), x,'linear','extrap');    
    end

    %%
%     if ishandle(1), close(1); end
%     figure(1)
%     subplot(131);
% 
%     plot(super_apo_old(:,2)); hold on
%     plot(super_apo_int(:,2)); hold on
%     plot(super_apo(:,2)); hold on
% 
%     subplot(132);
% 
%     plot(deep_apo_old(:,2)); hold on
%     plot(deep_apo_int(:,2)); hold on
%     plot(deep_apo(:,2)); hold on
% 
%     subplot(133);
% 
%     plot(alpha_old); hold on
%     plot(alpha_int); hold on
%     plot(alpha); hold on
    
    %% replace
    super_apo = super_apo_int;
    deep_apo = deep_apo_int;
    alpha = alpha_int;
end

%% re-run TimTrack
if parms.makeGIF
    GIF_filename = input('Please provide GIF filename','s');
    gif([GIF_filename,'.gif']) 
end

figure(2)
[n,m,p] = size(parms.image_sequence(:,:,1));

for i = 1:length(geofeatures)
    
    data_padded = [ones(n,round(m/2),p) parms.image_sequence(:,:,i) ones(n,round(m/2),p)];     % zero padding

    super_coef = fit_apo(parms.apo.apox(isfinite(super_apo(i,:))),super_apo(i, isfinite(super_apo(i,:))),parms.apo.super, parms.apo.super.order);
    deep_coef = fit_apo(parms.apo.apox(isfinite(deep_apo(i,:))),deep_apo(i, isfinite(deep_apo(i,:))),parms.apo.deep, parms.apo.super.order);
    
    % linear versions
    super_coef_lin = fit_apo(parms.apo.apox(isfinite(super_apo(i,:))),super_apo(i, isfinite(super_apo(i,:))),parms.apo.super, 1);
    deep_coef_lin = fit_apo(parms.apo.apox(isfinite(deep_apo(i,:))),deep_apo(i, isfinite(deep_apo(i,:))),parms.apo.deep, 1); 
    
    if parms.extrapolation
    
        Mx = round(m/2);
        My = mean([polyval(deep_coef_lin, Mx) polyval(super_coef_lin, Mx)]);

        fas_coef(1) = -tand(alpha(i));
        fas_coef(2) =  My - Mx * fas_coef(1);

        parms.apo.x = round(fzero(@(x) polyval(deep_coef_lin(:)-fas_coef(:),x),0));
    
    end
    
    imshow(data_padded,'xdata',[-round(m/2) round(1.5*m)], 'ydata',[1 n]);
    make_us_figure(parms.image_sequence(:,:,i), deep_apo(i,:), super_apo(i,:), alpha(i), super_coef, deep_coef, parms);
    drawnow
    
    if parms.makeGIF, gif;
    end
    
    % extract variables
    fat_thickness = round(mean(super_apo,'omitnan'));
    betha = -atan2d(super_coef_lin(1),1);
    gamma = -atan2d(deep_coef_lin(1),1);
    muscle_thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
    faslen = muscle_thickness ./ sind(alpha(i)-betha);

    extrapolated_fraction = (faslen - m/cosd(alpha(i))) / faslen;

    % store
    geofeatures(i).gamma = gamma;
    geofeatures(i).betha = betha;
    geofeatures(i).thickness = muscle_thickness;
    geofeatures(i).faslen = faslen;
    geofeatures(i).alpha = alpha(i);
    geofeatures(i).phi = alpha(i)-betha;
    geofeatures(i).fat_thickness = fat_thickness;
    geofeatures(i).extrapolated_fraction = extrapolated_fraction;

    apovecs(i).super_aponeurosis_vector = super_apo(i,:);
    apovecs(i).deep_aponeurosis_vector = deep_apo(i,:);
    
end