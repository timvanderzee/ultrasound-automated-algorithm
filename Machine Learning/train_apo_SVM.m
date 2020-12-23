function[SVMModel, X, Y] = train_apo_SVM(randdata,parms,type)

Y = nan(10,1);
X = nan(10,4);

for i = 1:20   
    data = rgb2gray(randdata(:,:,:,i));
    
    [~, super_filt, deep_filt] = filter_usimage(data,parms);
    
    if strcmp(type, 'super')
        aponeurosis = super_filt;
    else
        aponeurosis = deep_filt;
    end
       
    
    disp(['# trues: ', num2str(sum(Y == 1))])
    disp(['# falses: ', num2str(sum(Y == 0))])
    
    if sum(Y == 1) > 2 && sum(Y == 0) > 2
        break
    end
    
    [X(i,:), Y(i)] = eval_SVM(data,aponeurosis);
end

SVMModel = fitcsvm(X,Y(:));
end