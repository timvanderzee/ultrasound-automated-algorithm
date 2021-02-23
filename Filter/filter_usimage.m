function[fas_thres, super_obj, deep_obj, th_apo] = filter_usimage(data,parms)

[n,m] = size(data);

% Frangi Filter
apo_filt = FrangiFilter2D(double(data), parms.apo.frangi);
fas_filt = FrangiFilter2D(double(data), parms.fas.frangi);

% deep aponeurosis in deep aponeurosis region
deep_apo_thres = imbinarize(data,'adaptive','sensitivity', parms.apo.th);
deep_apo = (deep_apo_thres.^parms.apo.filtfac) .* apo_filt;
deep_apo(1:round(parms.apo.deep.cut(1)*n),:) = 0;  
deep_apo((round(parms.apo.deep.cut(2)*n):end),:) = 0; 
deep_apo = imgaussfilt(deep_apo,parms.apo.sigma);
deep_apo = imbinarize(deep_apo);
deep_obj = bwpropfilt(deep_apo,'majoraxislength',1,'largest');

% superficial aponeurosis in superficial aponeurosis region
super_apo_thres = imbinarize(data,'adaptive','sensitivity', parms.apo.th);
super_apo = (super_apo_thres.^parms.apo.filtfac) .* apo_filt;
super_apo(1:round(parms.apo.super.cut(1)*n),:) = 0;  
super_apo(round(parms.apo.super.cut(2)*n):end,:) = 0;  
super_apo = imgaussfilt(super_apo,parms.apo.sigma);
super_apo = imbinarize(super_apo);
super_obj = bwpropfilt(super_apo,'majoraxislength',1,'largest');

% fascicle
fas_thres = imbinarize(fas_filt,parms.fas.th);
fas_thres = fas_thres - super_apo - deep_apo;
fas_thres(fas_thres<0) = 0;

%% For image
% sum of aponeurosis
th_apo = deep_obj + super_obj;
th_apo(th_apo > 1) = 1;

% sum of all
th_image = th_apo + fas_thres;
th_image(th_image>1) = 1;

if parms.apo.show
    figure;
    subplot(121);
    imshow(th_image);
    
    color = get(gca,'colororder');

    for i = 1:2
        line('xdata', [1 m] , 'ydata', n.*[parms.apo.super.cut(i) parms.apo.super.cut(i)],...
            'linewidth',2, 'linestyle', '--', 'color', color(6,:))

        line('xdata', [1 m] , 'ydata', n.*[parms.apo.deep.cut(i) parms.apo.deep.cut(i)],...
            'linewidth',2, 'linestyle', '--', 'color', color(5,:))
    end
    title('Filtered image')
    
    subplot(122);

 set(gcf,'units','normalized','position', [.1 .3 .6 .3])
end

end