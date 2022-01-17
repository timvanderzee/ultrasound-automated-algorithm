function[fas_thres, super_obj, deep_obj] = filter_usimage(data,parms)

% Determine size
[n,m] = size(data);

% Attempt to avoid boundary effects (neccesary?)
% data(data == 0) = mean(data(:));

%% Aponeurosis
if strcmp(parms.apo.method,'Frangi')
    % Frangi Filter
    apo_filt = FrangiFilter2D(double(data), parms.apo.frangi); % filtered aponeurosis image

    % Aponeurosis objects from object detection
    super_obj = get_apo_obj(data, apo_filt, parms.apo.super.cut, parms.apo); % superficial aponeurosis object
    deep_obj = get_apo_obj(data, apo_filt, parms.apo.deep.cut, parms.apo); % deep aponeurosis object

elseif strcmp(parms.apo.method, 'Hough')
    % Aponeurosis objects from Hough lines
    super_obj = get_apo_line(data, parms.apo.super.cut, parms.apo); % superficial aponeurosis object
    deep_obj = get_apo_line(data, parms.apo.deep.cut, parms.apo); % superficial aponeurosis object
end

%% Fascicle
% Frangi Filter
fas_filt = FrangiFilter2D(double(data), parms.fas.frangi);  % filtered fascicle image

% Fascicle image
fas_thres = imbinarize(fas_filt,'adaptive','sensitivity', parms.fas.th); % threshold
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

%% Functions for aponeurosis object detection
function[apo_obj] = get_apo_obj(data, apo_filt, cut, parms)
    
    % for compatibility: define filter method if not already done
    if ~isfield(parms,'filter_method'), parms.filter_method = 'multiply';
    end
    
    if strcmp(parms.filter_method, 'multiply')
        % step 1.1c: threshold unfiltered image
        apo_thres = imbinarize(data,'adaptive','sensitivity', parms.th); 

        % step 1.2b: multiply thresholded with filtered image
        apo_thresfilt = apo_thres .* apo_filt.^parms.filtfac; 

    % else just treshold filtered image
    else apo_thresfilt = imbinarize(apo_filt,'adaptive','sensitivity', parms.th);
    end
    
    % cut region of interest
    apo_thresfilt(1:round(cut(1)*n),:) = 0;  
    apo_thresfilt((round(cut(2)*n):end),:) = 0; 
    
%     step 1.3: gaussian filtering
    apo_gaussfilt = imgaussfilt(apo_thresfilt, parms.sigma); 

%     step 1.4: second thresholding
    apo_gaussfilt_thres = imbinarize(apo_gaussfilt,'adaptive','sensitivity', parms.th);

    % step 2: select objects
    apo_objs = bwpropfilt(apo_gaussfilt_thres,'majoraxislength',2,'largest'); % get two largest objects
    apo_props = regionprops(apo_objs, apo_gaussfilt_thres, 'MeanIntensity','Majoraxislength'); % get their properties

    % if close call, chose the one with the highest mean intensity. if not,
    % chose longest
    if min(apo_props.MajorAxisLength) / max(apo_props.MajorAxisLength) > parms.maxlengthratio
        apo_obj = bwpropfilt(apo_objs,apo_filt,'MeanIntensity',1,'largest');
    else apo_obj = bwpropfilt(apo_objs,'majoraxislength',1,'largest');
    end
end

function[apo_obj] = get_apo_line(data, cut, parms)
    
    apo_thres = imbinarize(data,'adaptive','sensitivity', parms.th); 
    
    apo_thres(1:round(cut(1)*n),:) = 0;  
    apo_thres((round(cut(2)*n):end),:) = 0; 
    
    % angle range
    hor_angles = parms.minangle:1:-1;
    anglerange = sort(90-hor_angles);
    anglerange(anglerange>90) = anglerange(anglerange>90) - 180;

    
    [H,T,R] = hough(apo_thres,'RhoResolution',0.5,'Theta',anglerange);
    P  = houghpeaks(H,1);
    Th = 90-T(P(:,2));
    Rh = R(P(:,1));

    [y,x] = find(hough_bin_pixels(apo_thres, T, R, P(1,:)));
    
    % interpolate
    xi = 1:size(data,2);
    yi = round(interp1(x,y,xi,'linear','extrap'));
    yi(yi>(size(data,1)-5)) = size(data,1)-5;
    
    apo_obj = zeros(size(data));
    apo_thickness = round(mean(parms.frangi.FrangiScaleRange)/2);
    for j = 1:length(xi)
        apo_obj((yi(j)-apo_thickness):(yi(j)+apo_thickness),xi(j)) = 1;
    end
end
end