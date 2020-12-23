function[apo_obj, SVM] = get_apo_obj(apo_filt, SVM)

[objects, n] = bwlabel(apo_filt);
Y = zeros(n,1);
score = zeros(n,2);

for i = 1:n
    object = objects == i;  

    X = get_apo_props(object);
    [Y(i), score(i,:)] = predict(SVM.model,X);
   
end


[~, idx] = max(score(:,2));
apo_obj = objects == idx;

end

