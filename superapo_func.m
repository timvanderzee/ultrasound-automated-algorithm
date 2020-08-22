function[super_simple] = superapo_func(aponeurosis, parms)

% parameters
apox = parms.apox;
cut = parms.cut;
super_simple = nan(size(apox));

% threshold
apo_thres = imbinarize(aponeurosis);

% keep to the top 40%
[m,~] = size(apo_thres);
apo_thres(cut(1)*m:end,:) = 0;  

% only consider objects with certain angle
apo_super_filt = bwpropfilt(apo_thres,'orientation', parms.superrange);

% pick the longest two objects
super_objs = bwpropfilt(apo_super_filt, 'majoraxislength',2);

% if its NOT a close call, throw away the smallest one
STATS = regionprops(super_objs,'majoraxislength');

if STATS(2).MajorAxisLength < parms.maxlengthratio*STATS(1).MajorAxisLength
    super_objs = bwareafilt(super_objs,1);
end

[super_objy,super_objx] = find(super_objs);

% choose the lowest points
for i = 1:length(apox)
    if sum(super_objx == apox(i)) > 0
        super_simple(i) = max(super_objy(super_objx == apox(i)));
    end
end   
