function[alpha, lines_out] = dohough(fascicle,parms)

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
anglerange = sort(90-parms.range);

%% Threshold, cut, edge
% determine size
[n,m,~] = size(fascicle);

% thresholding
fas_thres = imbinarize(fascicle,parms.thres);

% cutting
fas_thres(1:(parms.middle-round(n*parms.cut(1))),:) = 0;
fas_thres(  (parms.middle+round(n*parms.cut(1))):end,:) = 0;
fas_thres(:,1:round(m*parms.cut(2))) = 0;
fas_thres(:, round(m*(1-parms.cut(2))):end,:) = 0;

% edge detection (not super critical I think)
fas_edge = edge(fas_thres);

%% Determine alpha
% hough transform
[hmat,theta,rho] = hough(fas_edge,'RhoResolution',parms.rhores,'Theta',anglerange(1):anglerange(2));

% find largest hmat value for each theta (i.e. each column)
hmax = nan(1,size(hmat,2));
for i = 1:size(hmat,2)
    hmax(i) = max(hmat(:,i));
end
[hnmax,maxid] = sort(hmax,'descend');

% weighted average
theta_wa = dot(theta(maxid(1:parms.npeaks)), hnmax(1:parms.npeaks)) / sum(hnmax(1:parms.npeaks));
alpha = 90 - theta_wa; % because hough is relative to vertical and we want relative to horizontal

%% Find most frequently occuring line
P = houghpeaks(hmat,1);
lines = houghlines(fas_edge,theta,rho,P,'FillGap',1000,'MinLength',1); % Fillgap is arbitrarily large and Minlength is arbitrarily small

if ~isempty(lines)
    lines_out = [lines(1).point1 lines(1).point2];
else
    lines_out = nan(1,4);
end
end
