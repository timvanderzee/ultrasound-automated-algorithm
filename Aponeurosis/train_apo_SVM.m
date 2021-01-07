function[SVMModel, X, Y] = train_apo_SVM(randdata,parms,type)

Y = [];
X = [];

for i = 1:10
    if size(randdata,4)>1
        data = rgb2gray(randdata(:,:,:,i));
    else
        data = randdata(:,:,i);
    end
    
    
    [~, super_filt, deep_filt] = filter_usimage(data,parms);
    
    if strcmp(type, 'super')
        aponeurosis = super_filt;
    else
        aponeurosis = deep_filt;
    end
       
    
    disp(['# trues: ', num2str(sum(Y == 1))])
    disp(['# falses: ', num2str(sum(Y == 0))])
   
    
    % get labeled data from aponeurosis image
    [Xnew, Ynew] = get_labeled_data(data,aponeurosis);
    
    X = [X; Xnew];
    Y = [Y; Ynew];
end

% train SVM model based on labeled data
SVMModel = fitcsvm(X,Y(:));
end