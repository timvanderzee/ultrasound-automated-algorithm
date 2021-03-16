function[alpha, betha, thickness, faslen,super_aponeurosis_vector,deep_aponeurosis_vector] = auto_ultrasound(data,parms)

[n,m] = size(data);
parms.apo.apox = round(linspace(parms.apo.apomargin, m-parms.apo.apomargin, parms.apo.napo));

%% Step 1: Filtering
[fascicle, super_obj, deep_obj] = filter_usimage(data,parms);

%% Step 2: Feature detection
super_aponeurosis_raw = apo_func(super_obj, parms.apo);
deep_aponeurosis_raw = n - (apo_func(flip(deep_obj), parms.apo));

% % Correct for width of Gaussian kernel
super_aponeurosis_vector = super_aponeurosis_raw - parms.apo.sigma;
deep_aponeurosis_vector = deep_aponeurosis_raw + parms.apo.sigma;

% Extrapolate deep aponeurosis
delta_apo = mean(diff(parms.apo.apox));
apox_extrap = (parms.apo.apomargin-delta_apo*parms.apo.nextrap):delta_apo:(parms.apo.apomargin-delta_apo);

%% Step 2b: Fascicle angle detection
% Determine fascicle region using detected aponeuroses
if isfinite(mean(deep_aponeurosis_vector)) && isfinite(mean(super_aponeurosis_vector))
    fascut = fascicle(round(mean(super_aponeurosis_vector)):round(mean(deep_aponeurosis_vector)),:);
else
    fascut = fascicle;
    disp('Warning: no aponeurosis object');
end

% Fascicle (Hough)
alpha = dohough(fascut,parms.fas);

%% Step 3: Variables extraction
% First order fit through vectors
super_coef = polyfit(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),1);
betha = -atan2d(super_coef(1),1);

deep_coef = polyfit(parms.apo.apox(isfinite(deep_aponeurosis_vector)),deep_aponeurosis_vector(isfinite(deep_aponeurosis_vector)),1);
gamma = -atan2d(deep_coef(1),1);

% non-extrapolated
super_aponeurosis_vector_int = polyval(super_coef,parms.apo.apox);
deep_aponeurosis_vector_int = polyval(deep_coef,parms.apo.apox);

heightvec = deep_aponeurosis_vector - super_aponeurosis_vector_int;
heightvec_int = deep_aponeurosis_vector_int - super_aponeurosis_vector_int;

thicknessvec = heightvec * cosd(betha);
thicknessvec_int = heightvec_int * cosd(betha);

faslenvec = thicknessvec ./ sind(alpha-betha);

% extrapolated
height_extrap = polyval(deep_coef,apox_extrap) - polyval(super_coef,apox_extrap);
thickness_extrap = height_extrap * cosd(betha);
faslen_extrap = thickness_extrap ./ sind(alpha-betha);

% evaluate thickness and fascicle length
thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = thickness ./ sind(alpha-betha);

%% Plot figure
if parms.show
   
    color = get(gca,'colororder');
    
    imshow(data);
    
    % aponeurosis vector locations
    for i = 1:length(parms.apo.apox)
        line('xdata', [parms.apo.apox(i) parms.apo.apox(i)], 'ydata', [1 n],'color',color(3,:))
    end
    
    % extrapolated lines
    line('xdata',-m:2*m, 'ydata', polyval(super_coef,-m:2*m),'linewidth',1, 'linestyle','-','color', color(6,:));
    line('xdata',-m:2*m, 'ydata', polyval(deep_coef,-m:2*m),'linewidth',1, 'linestyle','-','color', color(5,:));
    xlim([-m 2*m]);
    
    % aponeurosis vectors
    line('xdata',parms.apo.apox(1:end-parms.apo.nexcl), 'ydata', deep_aponeurosis_vector(1:end-parms.apo.nexcl),'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(5,:).^5,'markerfacecolor',color(5,:))
    line('xdata',parms.apo.apox(1:end-parms.apo.nexcl), 'ydata', super_aponeurosis_vector(1:end-parms.apo.nexcl),'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(6,:).^5,'markerfacecolor',color(6,:))
   
    % excluded points on aponeurosis vectors
    line('xdata',parms.apo.apox(end-parms.apo.nexcl+1:end), 'ydata', deep_aponeurosis_vector(end-parms.apo.nexcl+1:end),'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(5,:),'markerfacecolor',[.5 .5 .5])
    line('xdata',parms.apo.apox(end-parms.apo.nexcl+1:end), 'ydata', super_aponeurosis_vector(end-parms.apo.nexcl+1:end),'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(6,:),'markerfacecolor',[.5 .5 .5])
    
    % extrapolated points on deep aponeurosis
    line('xdata',apox_extrap, 'ydata', polyval(deep_coef,apox_extrap),'linewidth',1, 'linestyle','-','marker','o','markersize',10,'color', color(5,:),...
        'markerfacecolor',[1 1 1])
       
    % extrapolated points on superficial aponeurosis from non-extrapolated fascicles
    line('xdata',parms.apo.apox(1:end-parms.apo.nexcl) + faslenvec(1:end-parms.apo.nexcl)*cosd(alpha), 'ydata', deep_aponeurosis_vector(1:end-parms.apo.nexcl) - faslenvec(1:end-parms.apo.nexcl)*sind(alpha),...
        'linewidth',1, 'linestyle','-','marker','o','markersize',10,'color', color(6,:), 'markerfacecolor',[1 1 1])

    % extrapolated points on superficial aponeurosis from extrapolated fascicles
    line('xdata', apox_extrap + faslen_extrap*cosd(alpha), 'ydata', polyval(deep_coef,apox_extrap) - faslen_extrap*sind(alpha),...
        'linewidth',1, 'linestyle','-','marker','o','markersize',10,'color', color(6,:), 'markerfacecolor',[1 1 1])    
    
    % non-extrapolated fascicles
    for u = 1:length(parms.apo.apox)-parms.apo.nexcl
        line('xdata', parms.apo.apox(u) + [0 faslenvec(u)*cosd(alpha)],...
             'ydata', deep_aponeurosis_vector(u) - [0 faslenvec(u)*sind(alpha)],'linewidth',1','linestyle','-', 'color', 'Red');
    end

    % extrapolated fascicles
    for u = 1:length(apox_extrap)
        line('xdata', apox_extrap(u) + [0 faslen_extrap(u)*cosd(alpha)],...
             'ydata', polyval(deep_coef,apox_extrap(u)) - [0 faslen_extrap(u)*sind(alpha)],'linewidth',1','linestyle','-', 'color', 'Red');
    end
    
    drawnow


end
    %% Plot fascicle length and thickness vs. longitudinal position
if parms.show2
    % thickness
    figure
    plot((apox_extrap - parms.apo.apomargin)/delta_apo, thickness_extrap/delta_apo,'ko','markersize',10,'markerfacecolor',[1 1 1]); hold on
    plot((parms.apo.apox(1:end-parms.apo.nexcl) - parms.apo.apomargin)/delta_apo, thicknessvec(1:end-parms.apo.nexcl)/delta_apo, 'ko','markersize',10,'markerfacecolor',[0 0 0])
    plot((parms.apo.apox(end-parms.apo.nexcl+1:end) - parms.apo.apomargin)/delta_apo, thicknessvec(end-parms.apo.nexcl+1:end)/delta_apo, 'ko','markersize',10,'markerfacecolor',[.5 .5 .5])

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

end
