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
   
    apo_thres = imbinarize(data,'adaptive','sensitivity', parms.apo.th); 
    
    apo_deep = apo_thres; apo_super = apo_thres;
    
    apo_deep(1:round(parms.apo.deep.cut(1)*n),:) = 0;  
    apo_deep((round(parms.apo.deep.cut(2)*n):end),:) = 0; 
    
    apo_super(1:round(parms.apo.super.cut(1)*n),:) = 0;  
    apo_super((round(parms.apo.super.cut(2)*n):end),:) = 0; 
    
    % Aponeurosis objects from Hough lines
    super_obj = get_apo_line(apo_super, parms.apo.apox, 'super'); % superficial aponeurosis object
    deep_obj = get_apo_line(apo_deep, parms.apo.apox, 'deep'); % deep aponeurosis object
end

%% Fascicle
% Frangi Filter
fas_filt = FrangiFilter2D(double(data), parms.fas.frangi);  % filtered fascicle image

% Fascicle image
fas_thres = imbinarize(fas_filt,'adaptive','sensitivity', parms.fas.th); % threshold

if sum(size(super_obj) == size(deep_obj)) < 2
    keyboard
end
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

function[apoy] = get_apo_line(apo_thres, apox, type)
    
    % perform Hough
    [hmat,theta,rho] = hough(apo_thres, 'Theta',[-90:89]);

    % angle of the line
    gamma = 90 - theta; % with horizontal
    
    % rotate to avoid horizontal bias
    rot_angle = 5; % [deg]
    apo_thres_rot = imrotate(apo_thres, rot_angle,'nearest', 'crop');
    [hmat_rot,~,~] = hough(apo_thres_rot,'Theta', 90-(rot_angle));
    
    % replace horizontal in original (with bias) with rotated one (without bias)
    hmat(:,theta == -90) = hmat_rot;

    % determine peaks
    P = houghpeaks(hmat, 1,'Threshold',0);
    Rho = rho(P(1)); Theta = theta(P(2));

    yi = round((Rho-apox * cosd(Theta)) ./ sind(Theta));
        
    % if horizontal, need to rotate these points back
    if Theta == -90
        yi = -round((Rho-apox * cosd(Theta+rot_angle)) ./ sind(Theta+rot_angle));
        
        [n,m] = size(apo_thres);
        center = round([m/2, n/2]);
        Cshift = [apox - center(1); yi - center(2)];
        R = [cosd(rot_angle) -sind(rot_angle); sind(rot_angle) cosd(rot_angle)];
        Crot = R * Cshift;
        Ctrans = [Crot(1,:) + center(1); Crot(2,:) + center(2)];

%         % plotting
%         plot(apox,yi); hold on
%         plot(center(2), center(1), 'o')
%         plot(Cshift(1,:), Cshift(2,:))
%         plot(Crot(1,:), Crot(2,:))
%         plot(Ctrans(1,:), Ctrans(2,:))

        yi = round(Ctrans(2,:));
    end

    apo_thres = imfill(apo_thres, 'holes');
    apoy = nan(size(apox));
        
    if strcmp(type, 'super')
        % if interpolate pixel is white, go and seek the first black pixel
        % you encounter moving down
        for i = 1:length(yi)
            if apo_thres(yi(i),apox(i)) || apo_thres(yi(i)+1, apox(i))
                apoy(i) = yi(i) + find(~apo_thres(yi(i)+1:end, apox(i)),1) - 1;
            else, apoy(i) = yi(i);
            end
        end
    elseif strcmp(type,'deep')
        % if interpolate pixel is white, go and seek the first black pixel
        % you encounter moving up
        for i = 1:length(yi)
            if apo_thres(yi(i),apox(i)) || apo_thres(yi(i)-1, apox(i))
                apoy(i) = find(~apo_thres(1:yi(i)-1, apox(i)),1, 'last') + 1;
            else, apoy(i) = yi(i);
            end
        end
    end
end
end