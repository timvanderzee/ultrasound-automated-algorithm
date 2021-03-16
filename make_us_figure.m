function[]= make_us_figure(data, deep_aponeurosis_vector, super_aponeurosis_vector, alpha, parms)

%% make some variables
% super fit
super_coef = polyfit(parms.apo.apox(isfinite(super_aponeurosis_vector)),super_aponeurosis_vector(isfinite(super_aponeurosis_vector)),1);
betha = -atan2d(super_coef(1),1);
super_aponeurosis_vector_int = polyval(super_coef,parms.apo.apox);

% deep fit
deep_coef = polyfit(parms.apo.apox(isfinite(deep_aponeurosis_vector)),deep_aponeurosis_vector(isfinite(deep_aponeurosis_vector)),1);
gamma = -atan2d(deep_coef(1),1);
deep_aponeurosis_vector_int = polyval(deep_coef,parms.apo.apox);

% from deep to fitted superficial
heightvec_deep = deep_aponeurosis_vector - super_aponeurosis_vector_int;
thicknessvec_deep = heightvec_deep * cosd(betha);
faslenvec_deep = thicknessvec_deep ./ sind(alpha-betha);

% from superficial to fitted deep
heightvec_super = deep_aponeurosis_vector_int - super_aponeurosis_vector;
thicknessvec_super = heightvec_super * cosd(gamma);
faslenvec_super = thicknessvec_super ./ sind(alpha-gamma);

% the chosen one
thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = thickness ./ sind(alpha-betha);

%% make figure
color = get(gca,'colororder');

% set(h,'units','normalized','position', [0 0 1 1])

[m,n,p] = size(data);

% zero padding
data_padded = [ones(m,n,p) data ones(m,n,p)];
imshow(data_padded,'xdata',[-n 2*n], 'ydata',[1 m]);

% fascicles from deep aponeurosis vector
for u = 1:length(parms.apo.apox)
    line('xdata', parms.apo.apox(u) + [0 faslenvec_deep(u)*cosd(alpha)],...
         'ydata', deep_aponeurosis_vector(u) - [0 faslenvec_deep(u)*sind(alpha)],'linewidth',1','linestyle','--', 'color', 'Red');
end

% fascicles from superficial aponeurosis vector
for u = 1:length(parms.apo.apox)
    line('xdata', parms.apo.apox(u) + [0 -faslenvec_super(u)*cosd(alpha)],...
         'ydata', super_aponeurosis_vector(u) + [0 faslenvec_super(u)*sind(alpha)],'linewidth',1','linestyle','--', 'color', 'Red');
end

% the chosen one
line('xdata', parms.apo.x + [0 faslen*cosd(alpha)], 'ydata', polyval(deep_coef, parms.apo.x) - [0 faslen*sind(alpha)],'color','Red', 'linewidth',2)

% fitted aponeuroses
line('xdata',-m:2*m, 'ydata', polyval(super_coef,-m:2*m),'linewidth',1, 'linestyle','-','color', color(6,:));
line('xdata',-m:2*m, 'ydata', polyval(deep_coef,-m:2*m),'linewidth',1, 'linestyle','-','color', color(5,:));

% aponeurosis vectors
line('xdata',parms.apo.apox, 'ydata', deep_aponeurosis_vector,'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(5,:).^5,'markerfacecolor',color(5,:))
line('xdata',parms.apo.apox, 'ydata', super_aponeurosis_vector,'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(6,:).^5,'markerfacecolor',color(6,:))


% axis([-2*m 2*m -2*m 2*m]);
% axis equal
% drawnow

    
end


