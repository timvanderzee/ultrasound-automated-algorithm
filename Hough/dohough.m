function[alphas] = dohough(fascicle,parms)

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
% r(2) = r(1);
th = linspace(0,2*pi) ;
xc = (r(2)*parms.w_ellipse_rel) + (r(2)*parms.w_ellipse_rel)*cos(th) ; 
% xc = r(2) + r(2)*cos(th); 
yc = r(1) + r(1)*sin(th); 
% plot(xc,yc,'r');

[nx,ny] = size(fascicle) ;
[X,Y] = meshgrid(1:ny,1:nx) ;
idx = inpolygon(X(:),Y(:),xc',yc);
fascicle_cut = fascicle;
fascicle_cut(~idx) = 0;
% fascicle_filt = bwpropfilt(fascicle_cut,'Orientation',parms.range);

% fascicle_filt = edge(fascicle_filt);
% fascicle_cut

%% Determine alpha
% hough transform
[hmat,theta,rho] = hough(fascicle_cut,'RhoResolution',parms.rhores,'Theta',fasangles);

% angle of the line itself
gamma = 90 - theta; % with horizontal

% relative radius of the ellipse
r_ellipse_rel = r(1) ./ sqrt(r(1)^2*cosd(gamma).^2 + r(2)^2*sind(gamma).^2);

% correct for relative radius
hmat_cor = round(hmat ./ repmat(r_ellipse_rel, size(hmat,1),1));

% determine peaks
P = houghpeaks(hmat_cor,parms.npeaks,'Threshold',0);
% 
% 
% % optional figure
%        figure(1), imshow(fascicle_filt), hold on
%        color = get(gca,'colororder');
% for i = 1:parms.npeaks
% Ps = houghpeaks(hmat_cor,parms.npeaks+1-i);
% 
%        lines = houghlines(fascicle_filt,theta,rho,Ps,'FillGap',5,'MinLength',7);
% 
% 
%        for k = 1:length(lines)
%          xy = [lines(k).point1; lines(k).point2];
%          plot(xy(:,1),xy(:,2),'LineWidth',2,'color',color(i,:));
%        end
% 
% end

% extract angles corresponding to peaks
alphas = gamma(P(:,2));
% gamma_sels = sort(gamma_sel);
% alpha = median(gamma_sels(3:end));

% alpha = prctile(gamma_sel, 75);

% % alpha: median of selected angles
% for i = 1:(length(gamma_sel)-1)
%     alphas(i) = median(gamma_sel(1:end-i));
% end
% 
% alpha = median(alphas);
    

%% Old method
% for i = 1:length(P)
%     hpeaks(i) = hmat(P(i,1),P(i,2));
% end
% 
% for i = 1:size(hmat,2)
%     [hmax(i), imax(i)] = max(hmat(:,i));
% end

% hmaxrel = hmax./r_ellipse;

% [hnmax,maxid] = sort(hmaxrel,'descend');
% hnmaxrel = hnmax - mean(hmaxrel);
% alpha = dot(gamma(maxid(1:parms.npeaks)), hnmaxrel(1:parms.npeaks)) / sum(hnmaxrel(1:parms.npeaks));
    
%% Figures
% figure
% imshow(imadjust(rescale(hmat)),'XData',theta,'YData',rho,...
%       'InitialMagnification','fit');
% 
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal;
% colormap(gca,hot);
% 
% ylim([0 500])
%        
% 
% figure
% imshow(imadjust(rescale(hmat_cor)),'XData',gamma,'YData',rho,...
%       'InitialMagnification','fit');
% 
% xlabel('\gamma'), ylabel('\gamma');
% axis on, axis normal;
% colormap(gca,hot);
% 
% hold on; plot(gamma_sel, rho(P(:,1)), 'o','color', color(1,:))
% plot([alpha alpha], [0 500],'-','color',color(1,:))
% 
% ylim([0 500])

    %% Figures
%     % fit by polygon
%     coef = polyfit(90-theta, mhmax,10);
%     
%     
%     figure(1)
%     plot(90-theta, hmax); hold on
%     plot(90-theta, mhmax,'k')
%     plot(90-theta(maxid(1:parms.npeaks)), hnmax(1:parms.npeaks), 'ko')
%     plot([alpha alpha], [0 150], 'k')
%     
%     plot(90-theta, polyval(coef,90-theta));
%     
% % % %     
%     figure(2)
%     colormap hot
%     surf(theta, rho, hmat,'Edgecolor','none'); hold on
%      ylim([0 400])    
% %     xticklabels(''); yticklabels(''); zticklabels('');
%     
%     figure(3)
%     colormap hot
%     surf(gamma, rho, hmat_cor,'Edgecolor','none'); hold on
%     ylim([0 400])    
% %     xticklabels(''); yticklabels(''); zticklabels('');
% 
% for i = 1:length(gamma_sel)
%     plot3(gamma_sel(i), rho(P(i,1)), hmat_cor(P(i,1),P(i,2)), 'o','color', color(1,:),'markerfacecolor',color(1,:))
% end
% 

%% 2D version
% figure;
%        imshow(imadjust(rescale(hmat_cor)),'XData',rho,'YData',gamma,...
%               'InitialMagnification','fit');
% 
% plot([alpha alpha], [0 400], 'color',color(1,:))

%     for t = 1:length(theta)
%         plot3(repmat(theta(t), length(rho),1), rho(:), hmat(:,t), 'color', sqrt(color(1,:)))
%     end
%    
% 
%     cd('C:\Users\Tim\OneDrive\Ultrasound')
%     exportgraphics(gcf, 'Hough3D_3.pdf','Resolution', 500)

end
