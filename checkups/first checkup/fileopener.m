[filename, pathname] = ...
     uigetfile({'*.m';'*.slx';'*.mat';'*.*'},'File Selector');
 fid = fopen(filename,'r');
 if fid == -1
    display('File failed to open')
    
    else
    A = dlmread(filename,'\t');

end