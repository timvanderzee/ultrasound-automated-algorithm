function[X,Y] = get_labeled_data(data,aponeurosis,type)    
       
% get_labeled_data gets labeled data from the aponeurosis image. 
%
% X: array containing the object properties
% Y: vector containing the labels (correct / incorrect)

if nargin == 2
    type = 'random';
end

% find objects in the image
[objects, n] = bwlabel(aponeurosis);

% select one object (either random or pick longest)
if strcmp(type,'random')
    rand_obj = ceil(n*rand(1,1));
    object = objects == rand_obj;      
elseif strcmp(type,'longest')
    object = bwareafilt(objects, 'majoraxislength', 1);
end

% find the edge of the object
[ox,oy] = find(edge(object));

% get some properties of the object
X = get_apo_props(object);

% visualize
figure;
imshow(data); hold on
plot(oy,ox,'.','linewidth',2)

% assign label to object (correct/incorrect)
Y = input('Right aponeurosis selected?');
close
    
end