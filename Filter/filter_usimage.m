function[fas_thres, super_apo, deep_apo] = filter_usimage(data,parms)

n = size(data,1);

% aponeurosis
apo_filt = FrangiFilter2D(double(data), parms.apo.frangi);

% deep
deep_apo = bwareaopen(imbinarize(data,'adaptive','sensitivity', parms.apo.deep.th),200) .* parms.apo.deep.filtfac .* apo_filt;
deep_apo(1:round(parms.apo.deep.cut(1)*n),:) = 0;  
deep_apo((round(parms.apo.deep.cut(2)*n):end),:) = 0;  
deep_apo = bwareaopen(imbinarize(deep_apo),400);
deep_apo = imfill(bwareaopen(deep_apo,200),'holes');

% superficial aponeurosis
super_apo = bwareaopen(imbinarize(data,'adaptive','sensitivity', parms.apo.super.th),200) .* parms.apo.super.filtfac .* apo_filt;
super_apo(1:round(parms.apo.super.cut(1)*n),:) = 0;  
super_apo(round(parms.apo.super.cut(2)*n):end,:) = 0;  
super_apo = bwareaopen(imbinarize(super_apo),400);
super_apo = imfill(bwareaopen(super_apo,200),'holes');

% fascicle
fascicle = FrangiFilter2D(double(data), parms.fas.frangi);
fas_thres = imbinarize(fascicle,parms.fas.th);

fas_thres = fas_thres - super_apo - deep_apo;
fas_thres(fas_thres<0) = 0;

th_image = deep_apo + super_apo + fas_thres;
th_image(th_image > 1) = 1;
th_image(th_image < 0) = 0;

if parms.apo.show
    figure;
    imshow(th_image);
end

end