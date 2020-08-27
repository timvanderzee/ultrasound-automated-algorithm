function[alpha, lines_out] = dohough(image,parms)

anglerange = sort(90-parms.range);

%% threshold, cut, edge
% thresholding
fascicle = imbinarize(image,parms.thres);
[n,m] = size(fascicle);

% cutting
fascicle(1:(parms.middle-round(n*parms.cut(1))),:) = 0;
fascicle(  (parms.middle+round(n*parms.cut(1))):end,:) = 0;
fascicle(:,1:round(m*parms.cut(2))) = 0;
fascicle(:, round(m*(1-parms.cut(2))):end,:) = 0;

% edge detection
fascicle = edge(fascicle);

%% do hough
% hough transform
[hmat,theta,rho] = hough(fascicle,'RhoResolution',parms.rhores,'Theta',anglerange(1):anglerange(2));

% find largest hmat value for each theta (i.e. each column)
hmax = nan(1,size(hmat,2));
for i = 1:size(hmat,2)
    hmax(i) = max(hmat(:,i));
end
[hnmax,maxid] = sort(hmax,'descend');

% weighted average
theta_wa = dot(theta(maxid(1:parms.npeaks)), hnmax(1:parms.npeaks)) / sum(hnmax(1:parms.npeaks));
alpha = 90 - theta_wa; % because hough is relative to vertical and we want relative to horizontal

% find lines
P = houghpeaks(hmat,1);
lines = houghlines(fascicle,theta,rho,P,'FillGap',1000,'MinLength',1); % Fillgap is arbitrarily large and Minlength is arbitrarily small

if ~isempty(lines)
    lines_out = [lines(1).point1 lines(1).point2];
else
    lines_out = nan(1,4);
end
end
