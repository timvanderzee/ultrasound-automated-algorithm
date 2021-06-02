function[fas_thres, super_obj, deep_obj] = filter_usimage(data,parms)

% Determine size
[n,m] = size(data);

% Frangi Filter
apo_filt = FrangiFilter2D(double(data), parms.apo.frangi); % filtered aponeurosis image
fas_filt = FrangiFilter2D(double(data), parms.fas.frangi);  % filtered fascicle image

% Aponeurosis objects
super_obj = get_apo_obj(data, apo_filt, parms.apo.super.cut, parms.apo); % superficial aponeurosis object
deep_obj = get_apo_obj(data, apo_filt, parms.apo.deep.cut, parms.apo); % deep aponeurosis object

% Fascicle image
fas_thres = imbinarize(fas_filt,'adaptive','sensitivity', parms.fas.th); % threshold
% fas_thres2 = imbinarize(fas_filt,parms.fas.th); % threshold
fas_thres(super_obj | deep_obj) = 0; % subtract aponeurosis objects

%% Optional: show image
if parms.apo.show
    subplot(121);
    imshow(deep_obj+super_obj+fas_thres);
    
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

%% Function for aponeurosis object detection
function[apo_obj] = get_apo_obj(data, apo_filt, cut, parms)
    
    % step 1.1c: threshold unfiltered image
    apo_thres = imbinarize(data,'adaptive','sensitivity', parms.th); 
    
    % step 1.2b: multiply thresholded with filtered image
    apo_thresfilt = apo_thres .* apo_filt.^parms.filtfac; 
    
    % cut region of interest
    apo_thresfilt(1:round(cut(1)*n),:) = 0;  
    apo_thresfilt((round(cut(2)*n):end),:) = 0; 
    
    % step 1.3: gaussian filtering
    apo_gaussfilt = imgaussfilt(apo_thresfilt, parms.sigma); 

    % step 1.4: second thresholding
    apo_gaussfilt_thres = imbinarize(apo_gaussfilt,'adaptive','sensitivity', parms.th);

    % step 2: select objects
    apo_objs = bwpropfilt(apo_gaussfilt_thres,'majoraxislength',2,'largest'); % get two largest objects
    apo_props = regionprops(apo_objs, apo_gaussfilt, 'MeanIntensity','Majoraxislength'); % get their properties

    % if close call, chose the one with the highest mean intensity. if not,
    % chose longest
    if min(apo_props.MajorAxisLength) / max(apo_props.MajorAxisLength) > parms.maxlengthratio
        apo_obj = bwpropfilt(apo_objs,apo_gaussfilt,'MeanIntensity',1,'largest');
    else apo_obj = bwpropfilt(apo_objs,'majoraxislength',1,'largest');
    end
end


end