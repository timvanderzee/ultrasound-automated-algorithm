function[Alphas_sel, w_sel] = dohough(fascicle,parms)

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

fasangles = anglerange(1):parms.thetares:anglerange(2);
re = parms.Emask_radius;

%% Determine alpha
% hough transform
[hmat,theta,rho] = hough(fascicle,'RhoResolution',parms.rhores,'Theta',fasangles);

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

% don't believe diagonal
w(alphas == 45) = 0;
P((alphas == 45),:) = [];

%% Optional figure: see which pixels contribute
N = size(P,1) ;
if parms.show
    % Most dominant line is green, least dominant is blue, intermediate are in between green and blue 
    colors = [ones(N,1) linspace(0,1,N)', linspace(0,1,N)'];
    
    for i = 1:N 
        [y,x] = find(hough_bin_pixels(fascicle, theta, rho, P(i,:)));
        line('xdata',x,'ydata',y ,'linestyle','none','marker','.', 'color',colors(i,:));
    end
end

%% Rotate and re-compute to avoid diagonal-bias
rot_angle = 20; % [deg]
fascicle_rot = imrotate(fascicle,rot_angle);
[hmat,theta,rho] = hough(fascicle_rot,'RhoResolution',parms.rhores,'Theta',fasangles);

% angle of the line itself
gamma = 90 - theta - rot_angle; % with horizontal

% relative radius of the ellipse
r_ellipse_rel = re(1) ./ sqrt(re(1)^2*cosd(gamma).^2 + re(2)^2*sind(gamma).^2);

% correct for relative radius
hmat_cor = round(hmat ./ repmat(r_ellipse_rel, size(hmat,1),1));

% determine peaks
P = houghpeaks(hmat_cor, parms.npeaks,'Threshold',0);

% extract angles corresponding to peaks
w_rot = nan(1,length(P));
for i = 1:length(P)
    w_rot(i) = hmat_cor(P(i,1),P(i,2));
end

alphas_rot = gamma(P(:,2));

% don't believe diagonal
w_rot(alphas_rot == 45-rot_angle) = 0;

% also ignore angles smaller than minimal angle
w_rot(alphas_rot < parms.range(1)) = 0;

% give non-rotated diagonal extra credit
w_rot(alphas_rot == 45) = w_rot(alphas_rot == 45) * 2;

%% lump rotated and non-rotated toghether
[wtot,i] = sort([w w_rot],'descend');
alphas_tot = [alphas alphas_rot];
Alphas = alphas_tot(i);
Alphas_sel = Alphas(1:parms.npeaks);
w_sel = wtot(1:parms.npeaks);

    
end
