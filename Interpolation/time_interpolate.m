function[geofeatures, apovecs] = time_interpolate(geofeatures, apovecs, parms, threshold)

for i = 1:length(geofeatures)
    super_apo(i,:) = apovecs(i).super_aponeurosis_vector;
    deep_apo(i,:) = apovecs(i).deep_aponeurosis_vector;
    alpha(i,:) = geofeatures(i).alpha;
    brightness(i,:) = geofeatures(i).brightness;
end

max_brighness = double(max(parms.image_sequence(:)));
brel = brightness/max_brighness;

id = brel < threshold;

%%
% figure
% for i = 1:length(geofeatures)
%     plot(super_apo(i,:)); hold on
% end

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
if ishandle(1), close(1); end
figure(1)
subplot(131);

plot(super_apo_old(:,2)); hold on
plot(super_apo_int(:,2)); hold on
plot(super_apo(:,2)); hold on

subplot(132);

plot(deep_apo_old(:,2)); hold on
plot(deep_apo_int(:,2)); hold on
plot(deep_apo(:,2)); hold on

subplot(133);

plot(alpha_old); hold on
plot(alpha_int); hold on
plot(alpha); hold on

%% fit
figure(2)
[n,m,p] = size(parms.image_sequence(:,:,1));

for i = 1:length(geofeatures)
    
    
    data_padded = [ones(n,m,p) parms.image_sequence(:,:,i) ones(n,m,p)];     % zero padding
    
    super_coef = fit_apo(parms.apo.apox(isfinite(super_apo_int(i,:))),super_apo_int(i, isfinite(super_apo_int(i,:))),parms.apo.super);
    deep_coef = fit_apo(parms.apo.apox(isfinite(deep_apo_int(i,:))),deep_apo_int(i, isfinite(deep_apo_int(i,:))),parms.apo.deep);

    if parms.extrapolation
    
        Mx = round(m/2);
        My = mean([polyval(deep_coef, Mx) polyval(super_coef, Mx)]);

        fas_coef(1) = -tand(alpha_int(i));
        fas_coef(2) =  My - Mx * fas_coef(1);

        parms.apo.x = round(fzero(@(x) polyval(deep_coef(:)-fas_coef(:),x),0));
    
    end
    
    imshow(data_padded,'xdata',[-m 2*m], 'ydata',[1 n]);
    make_us_figure(parms.image_sequence(:,:,i), deep_apo_int(i,:), super_apo_int(i,:), alpha_int(i), super_coef, deep_coef, parms);
    drawnow

end