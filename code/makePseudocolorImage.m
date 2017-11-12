
clc; close all; clear

imG = imread('greenIm.png');
% imG = imread('Green1_MAX_aac.tif');
imR = imread('redIm.png');

clc; close all;
fh1=figure('Units','normalized','OuterPosition',[.02 .06 .97 .8],'Color','w');
hax1 = axes('Position',[.05 .07 .40 .85],'Color','none');
hax2 = axes('Position',[.52 .07 .40 .85],'Color','none');


nc = 100;

hg = zeros(nc,3);
hg(1:nc,2) = linspace(0,1,nc);

hr = zeros(nc,3);
hr(1:nc,1) = linspace(0,1,nc);


axes(hax1); 
colormap(hax1, hg );
imagesc(imG)


axes(hax2); 
colormap(hax2, hr );
imagesc(imR)

% Imax = max(max(max(imR)));
% Imin = min(min(min(imR)));
% cmax = Imax - (Imax-Imin)/20;
% cmin = Imin + (Imax-Imin)/20;
% hax2.CLim=[cmin cmax];


imA = double(imG) - double(imR);


clc; close all;
fh1=figure('Units','normalized','OuterPosition',[.02 .06 .7 .8],'Color','w');
hax1 = axes('Position',[.05 .07 .85 .85],'Color','none');

nc = 100;

Cs = colormap(summer); 
% Cs = min(Cs) max(Cs); 
% hg = zeros(nc,3);
% hg(1:nc,2) = linspace(0,1,nc);
Ca = flipud(colormap(autumn));
C = flipud([Cs; Ca]);

hg = zeros(nc,3);
hg(1:nc,2) = linspace(0,1,nc);

axes(hax1); 
colormap(hax1, C );
imagesc(imA)


