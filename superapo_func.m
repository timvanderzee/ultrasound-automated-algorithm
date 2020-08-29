function[super_simple] = superapo_func(aponeurosis, parms)

% This function finds vertical coordinates of the superficial aponeurosis object
% given the filtered image(aponeurosis) and parameters (parms)

% Outputs:
    % super_simple: vertical location of the deepest pixels on the superficial aponeurosis

% Inputs:
    % aponeurosis: filtered aponeurosis image (nxmx3)
    % parms: struct containing parameter values in its fields
    
% Tim van der Zee 2020-08-29

% define output
super_simple = nan(size(parms.apox));

% determine size
[n,~,~] = size(aponeurosis);

% threshold
apo_thres = imbinarize(aponeurosis);

% select region
apo_thres(round(parms.cut(1)*n):end,:) = 0;  

% filter for angles
apo_super = bwpropfilt(apo_thres,'orientation', parms.superrange);

% find the two longest objects
two_longest = bwpropfilt(apo_super, 'Majoraxislength',2);

%% Decision: if its NOT a close call, choose the longest (else, implicitly choose the deepest)
props = regionprops(two_longest,'Majoraxislength');

if min(props.MajorAxisLength) < (parms.maxlengthratio * max(props.MajorAxisLength))
    two_longest = bwareafilt(two_longest,1); % choose the longest
end

% find x and y locations on object
[super_objy,super_objx] = find(two_longest);

% choose the deepest points
for i = 1:length(parms.apox)
    if sum(super_objx == parms.apox(i)) > 0
        super_simple(i) = max(super_objy(super_objx == parms.apox(i)));
    end
end 
end
