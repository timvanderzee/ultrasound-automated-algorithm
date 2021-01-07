function[X,Y] = get_labeled_data(data,aponeurosis)    
       
% get_labeled_data gets labeled data from the aponeurosis image. 
%
% X: array containing the object properties
% Y: vector containing the labels (correct / incorrect)


% find objects in the image
[objects, n] = bwlabel(aponeurosis);

X = nan(n, 4);
Y = nan(n,1);

is = randperm(n);

for i = 1:n

    object = objects == is(i);
    
% find the edge of the object
[ox,oy] = find(edge(object));

% get some properties of the object
X(i,:) = get_apo_props(object);

% visualize
figure;
subplot(211);
imshow(data); hold on
plot(oy,ox,'.','linewidth',2)

subplot(212);
imshow(aponeurosis); hold on
plot(oy,ox,'.','linewidth',2)

% assign label to object (correct/incorrect)
Y(i,1) = input('Right aponeurosis selected?');

close
if Y(i,1) == 1
    return
end

end
end