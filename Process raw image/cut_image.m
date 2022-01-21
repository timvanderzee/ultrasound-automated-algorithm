function[ROI] = cut_image(image)

figure; 
imshow(image); hold on;

for i = 1:2
    if i == 1, title('Click in the top-left of the image');
    elseif i == 2, title('Click in the bottom-right of the image');
    else, title('Click where red line intersects deep aponeurosis');
    end
    
%     if i == 3
%         plot([mean([rx(1) rx(2)]) mean([rx(1) rx(2)])], [ry(1) ry(2)], 'r-')
%     end

    [x,y] = ginput(1);

    rx(i) = round(x);
    ry(i) = round(y);
    
    
    plot(x,y,'r.','markersize',20) 
end

% % adjust so that deep aponeurosis is at 80% of image depth
% if (ry(3)-ry(1)) < .8 * (ry(2) - ry(1))
%     ry(2) = ry(1) + (ry(3)-ry(1)) ./ .8;
% end

% plot lines
plot([rx(1) rx(2)], [ry(1) ry(1)],'r')
plot([rx(1) rx(2)], [ry(2) ry(2)],'r')
plot([rx(1) rx(1)], [ry(1) ry(2)],'r')
plot([rx(2) rx(2)], [ry(1) ry(2)],'r')

ROI = [rx(1:2); ry(1:2)];
close;

end