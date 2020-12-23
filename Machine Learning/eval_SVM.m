function[X,Y] = eval_SVM(data,aponeurosis,type)    
       
if nargin == 2
    type = 'random';
end

[objects, n] = bwlabel(aponeurosis);

if strcmp(type,'random')
    rand_obj = ceil(n*rand(1,1));
    object = objects == rand_obj;      
elseif strcmp(type,'longest')
    object = bwareafilt(objects, 'majoraxislength', 1);
end


[ox,oy] = find(edge(object));

X = get_apo_props(object);

figure;
imshow(data); hold on
plot(oy,ox,'.','linewidth',2)
Y = input('Right aponeurosis selected?');
close

    
end