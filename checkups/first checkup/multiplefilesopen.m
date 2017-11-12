[filename, pathname] = ...
     uigetfile({'*.m';'*.slx';'*.mat';'*.*'},'File Selector');
 fid = fopen(filename,'r');
 if fid == -1
    display('File failed to open')
    
    else
    A = xlsread(filename);

 end
%% separates the matrix

[~, names] = xlsread(filename, 'A:A');
names = names(2:end);
filenames = strcat(names, '.txt')

