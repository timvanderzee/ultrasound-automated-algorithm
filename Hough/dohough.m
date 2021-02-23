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

    figure;
    color = get(gca,'colororder');
    close

if strcmp(parms.houghangles,'default')== 1
    anglerange = [-90 89];
else
    anglerange = sort(90-parms.range);
end

fasangles = anglerange(1):parms.thetares:anglerange(2);

%% Threshold, cut, edge
% determine size
[n,m,~] = size(fascicle);

% for each theta, find the rho that has the highest accumulator value
hmax = nan(3,length(fasangles));
imax = nan(3,length(fasangles));

for side = 1:3
fas_thres = fascicle(parms.middle-round(parms.cut(1)):parms.middle+round(parms.cut(1)),:);

if side == 1, fas_thres = fas_thres(:,10:round(2*parms.cut(1))+10); 
elseif side == 2, fas_thres = fas_thres(:,round(m/2-parms.cut(1)):round(m/2+parms.cut(1))); 
elseif side == 3, fas_thres = fas_thres(:,m-(round(2*parms.cut(1))+10):(m-10)); 
end

% if side == 2
%    keyboard
% end

   %% Determine alpha
% hough transform
[hmat,theta,rho] = hough(fas_thres,'RhoResolution',parms.rhores,'Theta',fasangles);

for i = 1:size(hmat,2)
    [hmax(side,i), imax(side,i)] = max(hmat(:,i));
end
end

    % Weighted average
	mhmax = mean(hmax);
    [hnmax,maxid] = sort(mhmax,'descend');

    % relative to minium
    hnmaxrel = hnmax - mean(mhmax);
    
    theta_wa = dot(theta(maxid(1:parms.npeaks)), hnmaxrel(1:parms.npeaks)) / sum(hnmaxrel(1:parms.npeaks));
    alpha = 90 - theta_wa; % because hough is relative to vertical and we want relative to horizontal
    
%     figure(1)
%     plot(90-theta, hmax); hold on
%     plot(90-theta, mhmax,'k')
%     plot(90-theta(maxid(1:parms.npeaks)), hnmax(1:parms.npeaks), 'ko')
%     plot([alpha alpha], [0 150], 'k')
% %     
%     figure(2)
%     colormap hot
%     surf(theta, rho, hmat,'Edgecolor','none'); hold on
%     h = plot3(theta, rho(imax(side,:)), hmax(side,:), 'ro');
%     set(h, 'Color',color(1,:),'markerfacecolor', sqrt(color(1,:)),'Markersize', 4)
%     ylim([0 250]);    xlim([10 80]); zlim([0 150])
%         
%     xticklabels(''); yticklabels(''); zticklabels('');
%     
%     for t = 1:length(theta)
%         plot3(repmat(theta(t), length(rho),1), rho(:), hmat(:,t), 'color', sqrt(color(1,:)))
%     end
%    
% 
%     cd('C:\Users\Tim\OneDrive\Ultrasound')
%     exportgraphics(gcf, 'Hough3D.pdf','Resolution', 500)

end
