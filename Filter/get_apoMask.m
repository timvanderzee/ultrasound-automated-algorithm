function[Emask,r] = get_apoMask(apo_thres,cut)

[n,m] = size(apo_thres);
% Mean aponeurosis depths
super_edge = cut(1) * n;
deep_edge = cut(2) * n;

% Create ellipse
r(1) = (deep_edge - super_edge) / 2;
r(2) = m/2;
th = linspace(0,2*pi);

% Ellipse boundary
xc = r(2) + r(2)*cos(th) ; 
yc = super_edge + r(1) + r(1)*sin(th); 

[nx,ny] = size(apo_thres);
[X,Y] = meshgrid(1:ny,1:nx) ;
idx = inpolygon(X(:),Y(:),xc',yc);

% Mask
Emask = zeros(size(apo_thres));
Emask(idx) = 1;

end