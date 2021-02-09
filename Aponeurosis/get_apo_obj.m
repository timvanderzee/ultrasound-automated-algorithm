function[apo_obj] = get_apo_obj(apo_filt, parms)

if strcmp(parms.method, 'SVM')
%% SVM
% get all objects in the image
[objects, n] = bwlabel(apo_filt);

% define variables
Y = zeros(n,1);
score = zeros(n,2);

% predict whether object is aponeurosis based on SVM model
for i = 1:n
    object = objects == i;  

    X = get_apo_props(object);
    [Y(i), score(i,:)] = predict(parms.SVM.model,X);
   
end

if sum(Y) == 0
    disp('Warning: could not find a suitable aponeurosis object')
end
% choose the object most likely to be aponeurosis (max. score value)
[~, idx] = max(score(:,2));
apo_obj = objects == idx;

else
    %% Just choose the longest
    apo_obj = bwpropfilt(apo_filt,'majoraxislength',1,'largest');
end
end

