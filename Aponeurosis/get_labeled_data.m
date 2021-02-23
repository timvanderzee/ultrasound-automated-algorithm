function[X,Y,apo_obj] = get_labeled_data(data,aponeurosis)    
       
% get_labeled_data gets labeled data from the aponeurosis image. 
%
% X: array containing the object properties
% Y: vector containing the labels (correct / incorrect)

% find objects in the image
[objects, n] = bwlabel(aponeurosis);
X = nan(n,12);
Y = nan(n,1);
[objx,objy] = find(edge(objects));

figure(1); imshow(data); hold on;  plot(objy,objx,'r.','linewidth',2)

%% Select aponeurosis
disp('Click on aponeurosis')
x = round(ginput(1));

%% Look which aponeurosis was select
for i = 1:n

    object = objects == i;
    
    % find the edge of the object
    [ox,oy] = find(object);

    % get some properties of the object
    X(i,:) = get_apo_props(object);

    % compare object to select aponeurosis
    Y(i,1) = sum(oy(ox == x(2)) == x(1));
    
    if Y(i,1)
        apo_obj = object;
        figure(1);
        plot(oy,ox,'r.','linewidth',2)
        drawnow
    end
    
end

   
%%
%     if sum(Y,'omitnan') < 1
%         % assign label to object (correct/incorrect)
%         Y(i,1) = input('Right aponeurosis selected?');
%     else
%         Y(i,1) = 0;
%     end
%     close


end