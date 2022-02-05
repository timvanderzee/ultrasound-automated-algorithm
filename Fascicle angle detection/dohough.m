function[alphas, w] = dohough(fascicle,parms)

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

% rotated hough transform (to avoid diagonal bias)
rot_angle = 20; % [deg]
fascicle_rot = imrotate(fascicle, rot_angle,'nearest', 'crop');
[hmat_rot,~,~] = hough(fascicle_rot,'RhoResolution',parms.rhores,'Theta', 90-(45+rot_angle));

% replace diagonal in original (with bias) with rotated one (without bias)
if 45 < parms.range(2) && 45 > parms.range(1)
    hmat(:,theta == 45) = hmat_rot;
%     hmat(:,theta == 45) = 0;
end

% angle of the line itself
gamma = 90 - theta; % with horizontal

% relative radius of the ellipse
r_ellipse_rel = re(1) ./ sqrt(re(1)^2*cosd(gamma).^2 + re(2)^2*sind(gamma).^2);

% correct for relative radius
hmat_cor = round(hmat ./ repmat(r_ellipse_rel, size(hmat,1),1));

% determine peaks
P = houghpeaks(hmat_cor, parms.npeaks,'Threshold',0);

% extract angles corresponding to peaks
w = nan(1,size(P,1));
for i = 1:size(P,1)
    w(i) = hmat_cor(P(i,1),P(i,2));
end

alphas = gamma(P(:,2));
% alpha = weightedMedian(alphas,w);

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

end
