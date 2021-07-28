function[]= make_us_figure(data, deep_aponeurosis_vector, super_aponeurosis_vector, alpha, super_coef, deep_coef, parms)

%% make some variables
% super fit
betha = -atan2d(super_coef(1),1);

% the chosen one
thickness = (polyval(deep_coef,parms.apo.x) - polyval(super_coef,parms.apo.x)) * cosd(betha);
faslen = thickness ./ sind(alpha-betha);

%% make figure
color = get(gca,'colororder');

% set(h,'units','normalized','position', [0 0 1 1])

[m,n,p] = size(data);

% zero padding
if parms.padding
    data_padded = [ones(m,n,p) data ones(m,n,p)];
    imshow(data_padded,'xdata',[-n 2*n], 'ydata',[1 m]);
    x = -n:2*n;
else
    imshow(data);
    x = 0:n;
end
    
% the chosen one
line('xdata', parms.apo.x + [0 faslen*cosd(alpha)], 'ydata', polyval(deep_coef, parms.apo.x) - [0 faslen*sind(alpha)],'color','Red', 'linewidth',2)

% fitted aponeuroses
line('xdata',x, 'ydata', polyval(super_coef,x),'linewidth',1, 'linestyle','-','color', color(6,:));
line('xdata',x, 'ydata', polyval(deep_coef,x),'linewidth',1, 'linestyle','-','color', color(5,:));

% aponeurosis vectors
line('xdata',parms.apo.apox, 'ydata', deep_aponeurosis_vector,'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(5,:).^5,'markerfacecolor',color(5,:))
line('xdata',parms.apo.apox, 'ydata', super_aponeurosis_vector,'linestyle','none','marker','o','markersize',10,'markeredgecolor',color(6,:).^5,'markerfacecolor',color(6,:))

% draw elippse
fascut = data(round(mean(super_aponeurosis_vector,'omitnan')):round(mean(deep_aponeurosis_vector,'omitnan')),:);
r = size(fascut)/2;
th = linspace(0,2*pi) ;
xc = (r(2)*parms.fas.w_ellipse_rel) + (r(2)*parms.fas.w_ellipse_rel)*cos(th) ; 
yc = r(1) + r(1)*sin(th) +  round(mean(super_aponeurosis_vector,'omitnan'));

line('xdata',xc, 'ydata', yc,'linestyle','--','color','red')

% axis([-2*m 2*m -2*m 2*m]);
% axis equal
drawnow

    
end


