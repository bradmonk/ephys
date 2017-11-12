%Test Script for Junmi's Project - by Tony Fung 2017%
%% start on a clean slate
clear all; clc; close all;
%% importing data option: GUI selector needs to choose "all file types", or else read from the .txt
[filename, pathname] = ...
     uigetfile({'*.m';'*.slx';'*.mat';'*.*'},'File Selector');
 fid = fopen(filename,'r');
 if fid == -1
    display('File failed to open')
    
    else
    A = dlmread(filename,'\t');

end
% separates time from sweeps
sweeps = A(:, 2:end);
time = A(:, 1);
plot (time, sweeps);
%lmao, remove semicolon above
%% iterating through sweeps and storing stats
[r,c] = size(sweeps);
windowmin = input('lower-bound time?');
windowmax = input('upper-bound time?');
%since it goes by 0.2 sec instead of 1 sec the indexing is off
windowmin = windowmin + 4* windowmin +1
windowmax = windowmax + 4* windowmax +1
% preallocated vectors for speed, otherwise changing vector size 
matmins = zeros(c-1);
mattimes = zeros(c-1);
matmaxs = zeros(c-1);
mattimesx = zeros(c-1);
for i = 2:c
    orig = A(:,i);
    %filtering out the noise
    smoothsweep = sgolayfilt(orig, 5, 25);
    %figure
    plot(time, orig, 'b',time, smoothsweep, 'r');
    grid on
    ax = axis;
    axis ([0,200, -250, 250]);
    xlabel('Sampling Time (sconds)')
    ylabel('Current (Amperes)')
    title('Filtering Noisy Sweep')
    
    [M, I] = min(smoothsweep(windowmin:windowmax));
    [Mx, Ix] = max(smoothsweep(windowmin:windowmax));
    realI = I+windowmin;
    realIx = I+windowmin;
  %stores everything for retrieval 
    matmins(i) = M;
    mattimes(i) = realI;
    matmaxs(i) = Mx;
    mattimesx(i) = realIx;
end
%% calculates ratios etc
czpomin = mean(matmins(2:27));
czpotime = mean(mattimes(2:27));
copomin = mean(matmins(53:78));
copotime = mean(mattimes(53:78));
czptmin = mean(matmins(104:128));
czpttime = mean(mattimes(104:128));
coptmin = mean(matmins(154:178));
copttime = mean(mattimes(154:178));
PoneRAT = czpomin/copomin
PtwoRAT = czptmin/coptmin

%% exports to an excel sheet

%% closes everything so it doesn't fuck up the workspace for other scripts
    clres = fclose('all');
    if clres == 0
        disp('File closed successfully')
    else
        disp('Error closing file')
    end

