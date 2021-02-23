function[ROI] = cut_image(image)

figure; 
imshow(image); hold on;

for i = 1:2
    [x,y] = ginput(1);
    plot(x,y,'r.','markersize',20) 
        
    rx(i) = round(x);
    ry(i) = round(y);

end

% plot lines
plot([rx(1) rx(2)], [ry(1) ry(1)],'r')
plot([rx(1) rx(2)], [ry(2) ry(2)],'r')
plot([rx(1) rx(1)], [ry(1) ry(2)],'r')
plot([rx(2) rx(2)], [ry(1) ry(2)],'r')

ROI = [rx; ry];
    
end