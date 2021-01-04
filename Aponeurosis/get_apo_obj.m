function[apo_obj, SVM] = get_apo_obj(apo_filt, SVM)

% get all objects in the image
[objects, n] = bwlabel(apo_filt);

% define variables
Y = zeros(n,1);
score = zeros(n,2);

% predict whether object is aponeurosis based on SVM model
for i = 1:n
    object = objects == i;  

    X = get_apo_props(object);
    [Y(i), score(i,:)] = predict(SVM.model,X);
   
end

% choose the object most likely to be aponeurosis (max. score value)
[~, idx] = max(score(:,2));
apo_obj = objects == idx;

end

