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

if strcmp(parms.houghangles,'default')== 1
    anglerange = [-90 89];
else
    anglerange = sort(90-parms.range);
end

fasangles = anglerange(1):parms.thetares:anglerange(2);

%% Threshold, cut, edge
% determine size
[n,m,~] = size(fascicle);

for side = 1:3
% thresholding
fas_thres = imbinarize(fascicle);

% cutting
fas_thres(1:(parms.middle-round(n*parms.cut(1))),:) = 0;
fas_thres(  (parms.middle+round(n*parms.cut(1))):end,:) = 0;

    if side == 1 % left
        fas_thres(:,1:10) = 0;
        fas_thres(:,round(2*n*parms.cut(1))+10:end) = 0;
        
    elseif side == 2 % middle
        fas_thres(:,1:round(m/2-n*parms.cut(1))) = 0;
        fas_thres(:,round(m/2+n*parms.cut(1)):end) = 0;
        
    else % right   
        fas_thres(:,(end-10):end) = 0;
        fas_thres(:,1:(end-(round(2*n*parms.cut(1))+10))) = 0;
    end
    
% edge detection (not super critical I think)
% fas_edge = edge(fas_thres);
fas_edge = fas_thres;

%% Determine alpha
% hough transform
[hmat,theta,rho] = hough(fas_edge,'RhoResolution',parms.rhores,'Theta',fasangles);

% find largest hmat value for each theta (i.e. each column)
hmax = nan(1,size(hmat,2));
for i = 1:size(hmat,2)
    hmax(i) = max(hmat(:,i));
end
[hnmax,maxid] = sort(hmax,'descend');

% weighted average
theta_wa = dot(theta(maxid(1:parms.npeaks)), hnmax(1:parms.npeaks)) / sum(hnmax(1:parms.npeaks));
alphas(side) = 90 - theta_wa; % because hough is relative to vertical and we want relative to horizontal

%% Find most frequently occuring line
P = houghpeaks(hmat,1);
lines = houghlines(fas_edge,theta,rho,P,'FillGap',1000,'MinLength',1); % Fillgap is arbitrarily large and Minlength is arbitrarily small

% figure;imshow(fascicle); hold on
% for k = 1:length(lines)
%  xy = [lines(k).point1; lines(k).point2];
%  plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% end
if ~isempty(lines)
    lines_out(:,:,side) = [lines(1).point1 lines(1).point2];
else
    lines_out(:,:,side) = nan(1,4);
end
end

alpha = median(alphas);

end
