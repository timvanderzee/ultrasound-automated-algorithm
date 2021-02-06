function[SVMModel, X, Y] = train_apo_SVM(randdata,parms,type)

Y = [];
X = [];

% if randdata is rgb, convert to grayscale
if size(randdata,4)>1
    for i = 1:size(randdata,4)
        data(:,:,i) = rgb2gray(randdata(:,:,:,i));
    end
else
    data = randdata;
end
    
for i = 1:min([parms.apo.ntraining, size(data,3)]) 
    [~, super_filt, deep_filt] = filter_usimage(data(:,:,i),parms);
    
    if strcmp(type, 'super')
        aponeurosis = super_filt;
    else
        aponeurosis = deep_filt;
    end
       
    
    disp(['# trues: ', num2str(sum(Y == 1))])
    disp(['# falses: ', num2str(sum(Y == 0))])
   
    
    % get labeled data from aponeurosis image
    [Xnew, Ynew] = get_labeled_data(data(:,:,i),aponeurosis);
    
    X = [X; Xnew];
    Y = [Y; Ynew];
end

% train SVM model based on labeled data
SVMModel = fitcsvm(X,Y(:));
end