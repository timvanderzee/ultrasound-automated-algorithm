function[alphas, w] = dohough(fascicle,fat_thickness,parms)

% This function finds the muscle fascicle angle (alpha) 
% given the filtered image (fascicle) and parameters (parms)

% Outputs:
    % alpha: muscle fascicle angle (with the horizontal)
    % lines_out: coordinates of line with the most frequently occuring
    % angle (for visualization purposes only)

% Inputs:
    % aponeurosis: filtered aponeurosis image (nxmx3)
    % parms: struct containing parameter values in its fields
    
% Tim van der Zee 2020-08-29

% Hough transform is done relative to the vertical, but we had things
% relative to the horizontal

    figure;
    color = get(gca,'colororder');
    close

if strcmp(parms.houghangles,'default')== 1
    anglerange = [-90 89];
else
    anglerange = sort(90-parms.range);
end

% second cut
[fx, fy] = find(fascicle);
fascicle = fascicle(min(fx):max(fx), min(fy):max(fy));

fasangles = anglerange(1):parms.thetares:anglerange(2);

%% Cut out ellipse
r = size(fascicle)/2;
th = linspace(0,2*pi);

% ellipse radius
re = [r(1), (r(2)*parms.w_ellipse_rel)];

xc = re(2) + re(2)*cos(th) ; 
yc = re(1) + re(1)*sin(th); 

[nx,ny] = size(fascicle) ;
[X,Y] = meshgrid(1:ny,1:nx) ;
idx = inpolygon(X(:),Y(:),xc',yc);
fascicle_cut = fascicle;
fascicle_cut(~idx) = 0;

%% Determine alpha
% hough transform
[hmat,theta,rho] = hough(fascicle_cut,'RhoResolution',parms.rhores,'Theta',fasangles);

% angle of the line itself
gamma = 90 - theta; % with horizontal

% relative radius of the ellipse
r_ellipse_rel = re(1) ./ sqrt(re(1)^2*cosd(gamma).^2 + re(2)^2*sind(gamma).^2);

% correct for relative radius
hmat_cor = round(hmat ./ repmat(r_ellipse_rel, size(hmat,1),1));

% determine peaks
P = houghpeaks(hmat_cor, parms.npeaks,'Threshold',0);

% extract angles corresponding to peaks
w = nan(1,length(P));
for i = 1:length(P)
    w(i) = hmat_cor(P(i,1),P(i,2));
end

alphas = gamma(P(:,2));

%% Optional figure: see which pixels contribute
% Most dominant line is green, least dominant is blue, intermediate are in between green and blue 
colors = [ones(parms.npeaks,1) linspace(0,1,parms.npeaks)', linspace(0,1,parms.npeaks)'];

Ps = houghpeaks(hmat_cor,parms.npeaks);
line('xdata',xc,'ydata',yc + fat_thickness,'linestyle','--','color','red');
for i = 1:parms.npeaks    
    [y,x] = find(hough_bin_pixels(fascicle_cut, theta, rho, Ps(i,:)));
    line('xdata',x,'ydata',y + fat_thickness,'linestyle','none','marker','.', 'color',colors(i,:));
end
    
end
