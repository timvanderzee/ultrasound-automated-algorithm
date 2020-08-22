function[deep_simple,apo_props] = deepapo_func(aponeurosis, parms)

% parameters
apox = parms.apox;
cut = parms.cut;
deep_simple = nan(size(apox));

% threshold
apo_thres = imbinarize(aponeurosis);

% only consider orientations between -20 and 10 degrees
apo_ori_filt = bwpropfilt(apo_thres,'orientation', parms.deeprange);

% region selection
[m,~] = size(apo_ori_filt);
apo_deep = apo_ori_filt;
apo_deep(1:(1-cut(1))*m,:) = 0;
apo_deep((1-cut(2))*m:end,:) = 0;

% find largest object
deep_obj2 = bwpropfilt(apo_deep,'MajorAxisLength',2);


%% if 2 long objects, choose the most superficial   
L = regionprops(apo_deep,'MajorAxisLength');

if length(L)>1
    if  L(2).MajorAxisLength > parms.maxlengthratio*L(1).MajorAxisLength
        prop = regionprops(deep_obj2,'extrema');

        for i = 1:length(prop)
            miny(i) = min(prop(i).Extrema(:,2));
        end

        [~,minloc] = min(miny);

        maxmin = round(max(prop(minloc).Extrema(:,2)));

        deep_obj2(maxmin:end,:) = 0;
    end
end

% largest of the two
deep_obj = bwareafilt(deep_obj2, 1);

%% Get properties
obj_props = regionprops(deep_obj,'MajorAxisLength','MinorAxisLength','Area');

apo_props.L1 = obj_props(1).MajorAxisLength;
apo_props.L2 = obj_props(1).MinorAxisLength;
apo_props.A = obj_props(1).Area;

%% Give up if too short
if apo_props.L1 < parms.minlength
    return
end

%% If you don't give up, do some processing
% fill holes
deep_obj = imfill(deep_obj, 'holes');

% extract the white pixel locations
[deep_objy,deep_objx] = find(deep_obj);

deepdeep = nan(size(apox)); % deepest pixel in deep object
supedeep = nan(size(apox)); % most superficial pixel in deep object

for i = 1:length(apox)
    % x-value exists for apox value, choose the maximum
    if sum(deep_objx == apox(i)) > 0
        deepdeep(i) = max(deep_objy(deep_objx == apox(i)));
        supedeep(i) = min(deep_objy(deep_objx == apox(i)));
    end
end  

% fill gaps between deepdeep and superdeep, if only 5 pixels
for i = 1:length(apox)
    if sum(deep_objx == apox(i)) > 0

        aposlice = deep_obj(supedeep(i):deepdeep(i),apox(i));
        if sum(aposlice) > (length(aposlice)-5)
            deep_obj(supedeep(i):deepdeep(i),apox(i)) = 1;
        end
    end
end  

% inverse image
[ideep_objy,ideep_objx] = find(~deep_obj);

% choose the first black pixel from the lowest white pixel
for i = 1:length(apox)
    % x-value exists for apox value, choose the maximum
    if sum(ideep_objx == apox(i)) > 0 && isfinite(deepdeep(i))
        ideep_objy_selec = ideep_objy(ideep_objx == apox(i));
        deep_simple(:,i) = max(ideep_objy_selec(ideep_objy_selec<deepdeep(i)));
    end
end  

