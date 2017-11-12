%% Junmi_Ephys.m
clc; close all; clear;

thisfile = 'Junmi_Ephys.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath); homedir = pwd;

%% IMPORT ALL .TXT FILES IN SELECTED DIR

filedir = uigetdir();
DataFiles = dir([filedir,'/*.txt']);
DataFileNames = {DataFiles(:).name}';
DataFileFullPaths = strcat(repmat([filedir '/'],length(DataFileNames),1), DataFileNames);

for nn = 1:size(DataFileFullPaths)

    DATASETS{nn} = importdata(DataFileFullPaths{nn},'\t');

end


%% IMPORT EPHYS DATASET

datasets = '/Users/bradleymonk/Documents/MATLAB/GIT/ephys/JunmiData';
datafiles = dir(datasets);
filenum = 3;
A = importdata([datafiles(filenum).folder filesep datafiles(filenum).name],'\t');
A0 = A;

TIME = A(:,1);
A(:,1) = [];

%% PLOT DATASET

% plot(  A( 300:600 , 3:48)  )
set(groot,'defaultLineLineWidth',.5)
close all; clc
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .8 .8],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
hax2 = axes('Position',[.05 .05 .9 .9],'Color','none');
axis off; hold on;

axes(hax1)
plot( TIME ,  A( : , 1:25)  , 'b')
hold on
plot( TIME ,  A( : , 26:50)  , 'c')
hold on
plot( TIME ,  A( : , 51:75)  , 'r')
hold on
plot( TIME ,  A( : , 76:100)  , 'm')
hold on

fh2=figure('Units','normalized','OuterPosition',[.1 .1 .8 .8],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
hax2 = axes('Position',[.05 .05 .9 .9],'Color','none');
axis off; hold on;

axes(hax1)
plot( A( : , 1:25)  , 'b')
hold on
plot( A( : , 26:50)  , 'c')
hold on
plot( A( : , 51:75)  , 'r')
hold on
plot( A( : , 76:100)  , 'm')
hold on


% pause(2)
% 
% set(groot,'defaultLineLineWidth',2)
% 
% ph1 = plot( TIME ,  A( : , nn)  , 'k');
% 
% for nn = 1:size(A,2)
% 
%     ph1.XData = TIME;
%     ph1.YData = A( : , nn);
%     % hold on
%     
%     pause(.5)
% 
% end

% CODE TO GET THE AREA UNDER THE CURVE
% close all
% plot(G3( : , 5))
% GIntegral = polyarea(  (1:numel(G3(:,5)))'  ,  [0; G3( : , 5); 0]  );


%% DATA ANALYSIS


G1 = A( 480:500 , 1:25);
G2 = A( 480:500 , 26:50);
G3 = A( 480:500 , 51:75);
G4 = A( 480:500 , 76:100);


G3mu = mean(G3);
G4mu = mean(G4);

G3sd = std(G3);
G4sd = std(G4);

G3sem = G3sd / sqrt(numel(G3));
G4sem = G4sd / sqrt(numel(G4));


G3G4mu = G3mu - G4mu;
G3G4sd = std(G3G4mu);
G3G4sem = G3G4sd / sqrt(numel(G3G4mu));

%% Bars with errorbars, coloured with a char array
close all; clc
fh3  = figure('Units','normalized','OuterPosition',[.1 .1 .8 .8],'Color','w');
hax3 = axes('Position',[.05 .05 .45 .9],'Color','none');
hax4 = axes('Position',[.52 .05 .45 .9],'Color','none');

axes(hax3)
superbar([G3mu; G4mu], 'E', [G3sem; G4sem]);

axes(hax4)
superbar( G3G4mu , 'E', G3G4sem );






