function[]= make_us_figure(data, deep_aponeurosis_vector, super_aponeurosis_vector, alpha, super_coef, deep_coef, parms)

%% make some variables
% super fit
betha = -atan2d(super_coef(1),1);

% the chosen one
thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = thickness ./ sind(alpha-betha);

x = min(parms.apo.apox):max(parms.apo.apox);

%% make figure
color = get(gca,'colororder');

[n,m,p] = size(data);

x = [min(parms.apo.apox):1:max(parms.apo.apox)];

% the chosen one
line('xdata', parms.apo.x + [0 faslen*cosd(alpha)], 'ydata', polyval(deep_coef, parms.apo.x) - [0 faslen*sind(alpha)],'color','Red', 'linewidth',2)

% fitted aponeuroses
line('xdata',x, 'ydata', polyval(super_coef,x),'linewidth',1, 'linestyle','-','color', color(6,:));
line('xdata',x, 'ydata', polyval(deep_coef,x),'linewidth',1, 'linestyle','-','color', color(5,:));

% aponeurosis vectors
line('xdata',parms.apo.apox, 'ydata', deep_aponeurosis_vector,'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(5,:).^5,'markerfacecolor',color(5,:))
line('xdata',parms.apo.apox, 'ydata', super_aponeurosis_vector,'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(6,:).^5,'markerfacecolor',color(6,:))
    
% aponeurosis region
line('xdata',[1 m], 'ydata', [round(parms.apo.deep.cut(1)*n) round(parms.apo.deep.cut(1)*n)], 'linewidth',1, 'linestyle','--','color', color(5,:));
line('xdata',[1 m], 'ydata', [round(parms.apo.deep.cut(2)*n) round(parms.apo.deep.cut(2)*n)], 'linewidth',1, 'linestyle','--','color', color(5,:));
line('xdata',[1 m], 'ydata', [round(parms.apo.super.cut(1)*n) round(parms.apo.super.cut(1)*n)], 'linewidth',1, 'linestyle','--','color', color(6,:));
line('xdata',[1 m], 'ydata', [round(parms.apo.super.cut(2)*n) round(parms.apo.super.cut(2)*n)], 'linewidth',1, 'linestyle','--','color', color(6,:));

end


