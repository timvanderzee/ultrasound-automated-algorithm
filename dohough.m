function[alpha, lines_out] = dohough(image,parms)
%% threshold, cut, edge
% thresholding
fascicle = imbinarize(image,parms.thres);
[n,m] = size(fascicle);

% cutting
fascicle(1:(parms.middle-round(n*parms.fascut(1))),:) = 0;
fascicle(  (parms.middle+round(n*parms.fascut(1))):end,:) = 0;
fascicle(:,1:round(m*parms.fascut(2))) = 0;
fascicle(:, round(m*(1-parms.fascut(2))):end,:) = 0;

% edge detection
fascicle = edge(fascicle);

%% do hough
% hough transform
[hmat,theta,rho] = hough(fascicle,'RhoResolution',parms.rhores,'Theta',parms.angles);

% find largest hmat value for each theta (i.e. each column)
hmax = maxk(hmat,1);
[hnmax,maxid] = maxk(hmax,parms.npeaks);

% weighted average
theta_wa = dot(theta(maxid), hnmax) / sum(hnmax);
alpha = 90 - theta_wa; % because hough is relative to vertical and we want relative to horizontal

% find lines
P = houghpeaks(hmat,1,'threshold', ceil(parms.houghthres*max(hmat(:))));
lines = houghlines(fascicle,theta,rho,P,'FillGap',parms.fillgap,'MinLength',parms.minlen);

if ~isempty(lines)
    lines_out = [lines(1).point1 lines(1).point2];
else
    lines_out = nan(1,4);
end
end
