function[Emask,r] = get_fasMask(fascicle, SAV, DAV, parms)

% Mean aponeurosis depths
mSAV = round(mean(SAV,'omitnan'));
mDAV = round(mean(DAV,'omitnan'));

% If aponeuroses exist: use them to cut fascicle region-of-interest
if isfinite(mSAV), fascicle(1:mSAV,:) = 0;
end
if isfinite(mDAV), fascicle(mDAV:end,:) = 0;
end

% Create ellipse
r(1) = (mDAV - mSAV) / 2;
r(2) = size(fascicle,2)/2;
th = linspace(0,2*pi);
% re = [r(1), (r(2)*parms.w_ellipse_rel)];

% Ellipse boundary
xc = r(2) + r(2)*cos(th) ; 
yc = mSAV+r(1) + r(1)*sin(th); 

[nx,ny] = size(fascicle);
[X,Y] = meshgrid(1:ny,1:nx) ;
idx = inpolygon(X(:),Y(:),xc',yc);

% Mask
Emask = zeros(size(fascicle));
Emask(idx) = 1;

if parms.show
   line('xdata',xc,'ydata',yc ,'linestyle','--','color','red');
end
end