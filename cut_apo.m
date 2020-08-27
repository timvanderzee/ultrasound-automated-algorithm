function[aponeurosis_cutted, verts, horis] = cut_apo(data,aponeurosis)
aponeurosis_cutted = aponeurosis;

%% horizontal lines
image = edge(imbinarize(rgb2gray(data)),'horizontal');
[hmat,theta,rho] = hough(image,'theta',-90);
P = houghpeaks(hmat,2,'threshold',ceil(0.1*max(hmat(:))));

% identify lines belonging to the found peaks
lines = houghlines(image,theta,rho,P,'FillGap',100,'MinLength',7);
for ilines = 1:length(lines)
    hori(ilines) = lines(ilines).point1(2);
end

%% vertical lines
image = edge(imbinarize(rgb2gray(data)),'vertical');
[hmat,theta,rho] = hough(image,'theta',0);
P = houghpeaks(hmat,2,'threshold',ceil(0.1*max(hmat(:))));

% identify lines belonging to the found peaks
lines = houghlines(image,theta,rho,P,'FillGap',100,'MinLength',7);
for ilines = 1:length(lines)
    vert(ilines) = lines(ilines).point1(1);
end

% correct vertical
if max(vert) < 500
vert(1) = max(vert);
vert(2) = 670;
end

% sorting
horis = sort(hori);
verts = sort(vert);

% do cutting
aponeurosis_cutted(1:horis(1)+20,:) = 0;
aponeurosis_cutted(horis(end)-20:end,:) = 0;
aponeurosis_cutted(:,1:verts(1)+30) = 0;
aponeurosis_cutted(:,verts(end)-30:end) = 0;


end