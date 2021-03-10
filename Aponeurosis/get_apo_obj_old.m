function[apo_obj,parms] = get_apo_obj(data, apo_filt, parms)

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
    
%     % longest two
%     apo_objs = bwpropfilt(apo_filt,'majoraxislength',2,'largest');
%     MAL = regionprops(apo_objs,'MajorAxisLength');
%     
%     % if close call
%     if min(MAL.MajorAxisLength) / max(MAL.MajorAxisLength) > .7
%         
%         % if SVM exists, let it decide
%         if ~isempty(parms.SVM.model)
%             [objects, n] = bwlabel(apo_filt);
% 
%             for i = 1:n
%                 object = objects == i;  
% 
%                 X = get_apo_props(object);
%                 [Y(i), score(i,:)] = predict(parms.SVM.model,X);
% 
%             end
%             
%             [~, idx] = max(score(:,2));
%             apo_obj = objects == idx;
%             
%             % if it doesn't exist, make it
%         else
%             
%         figure;
%         [parms.SVM.X,parms.SVM.Y, apo_obj] = get_labeled_data(data,apo_objs);
%          parms.SVM.model = fitcsvm(parms.SVM.X, parms.SVM.Y(:));
%         end
%     else
    
        % if not a close call: pick longest
        apo_obj = bwpropfilt(apo_filt,'majoraxislength',1,'largest');
%     end
end
end

