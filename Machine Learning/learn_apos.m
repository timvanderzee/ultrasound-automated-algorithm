clear all; close all;

%%
cd('C:\Users\Tim\Documents\GitHub\ultrasound-automated-algorithm\Machine Learning')
d = dir(cd);
show = 1;

for i = 1:(length(d)-7)
    load(d(i+3).name)
    
   [X(i,:), y(i)] = get_apo_props(data,two_longest,show);
   
end

%% Evaluate
load('00SVM.mat','X','Y');

SVMModel = fitcsvm(X,Y(:));
% predy = predict(SVMModel,X);

% mistakes = sum(y-predy);

save('00SVM.mat','SVMModel','Y','X');

return
%% Visualize
cd('C:\Users\Tim\Documents\GitHub\ultrasound-automated-algorithm\Machine Learning')
d = dir(cd);
load('00SVM.mat');

for i = 1:(length(d)-7)
    
    load(d(i+3).name)
    
    [predy2(i,:), X2(i,:)] = eval_SVM(SVMModel, two_longest);

    if predy2(i) == 1
       apo_obj = bwpropfilt(two_longest,'Majoraxislength',1); % choose the longest
    else
       apo_obj = bwpropfilt(two_longest,'Majoraxislength',1,'smallest'); % choose the smallest
    end
    
    longest = bwpropfilt(two_longest, 'Majoraxislength',1);
    shortest = bwpropfilt(two_longest, 'Majoraxislength',1,'smallest');
    
    [lox,loy] = find(edge(longest));
    [sox,soy] = find(edge(shortest));
    [ox,oy] = find(edge(apo_obj));
    
%     figure;
%     imshow(data); hold on
%     
%     plot(loy,lox,'.','linewidth',2)
%     plot(soy,sox,'.','linewidth',2)
%     plot(oy,ox,'.','linewidth',2)
   
    
%    pause
    
end


