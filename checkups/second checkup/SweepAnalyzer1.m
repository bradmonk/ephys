%% start on a clean slate
clear all; clc; close all;
%opens sweepcount excel file
[filename, pathname] = ...
     uigetfile({'*.m';'*.slx';'*.mat';'*.*'},'File Selector');
 fid = fopen(filename,'r');
 if fid == -1
    display('File failed to open')
    
    else
    A = xlsread(filename);

 end
 %%
 progressbar('Progress')
%% Gets names of the sweep .txt files to open and stores relevant channel and patch indices in positions
[~, names] = xlsread(filename, 'A:A');
names = names(2:end);
filenames = strcat(names, '.txt');
[sweepfileindex] = size(filenames);
% get the sweepcounts for each channel and patch
positions = A(:,1:16);
positions = positions -1;
[row,col] = size(positions);
infectstatus = A(:,17);
newpositions = zeros(row,col);
for t = 1:size(infectstatus)
    if infectstatus(t) == 1; %the index in sweepcount column of which is infected has value of 1 then switch czpomin and copomin
        %switch
        for m = 2:2:12
            
            [newpositions(t,m),newpositions(t,m+4)] = deal(positions(t,m+4),positions(t,m));
            
        end
        else
            newpositions = positions;
   
    end
end
progressbar(0.1)
scatterindices = sum(newpositions);
%% loops through each filename, reading each recording
%patch one (channel zero:channel one) and patch two ratios 
% predetermining matrices sizes so the script runs faster, by making a
% matrix of zeros for each, and replacing them 
outputstr = 'Infected to Uninfected: (%f +/- %f) / (%f +/- %f) \n';
%ampa stuff
PoneRAT = cell([1,sweepfileindex]);
PoneRATtime = cell([1,sweepfileindex]);
PtwoRAT = cell([1,sweepfileindex]);
PtwoRATtime = cell([1,sweepfileindex]);
    oneinfect = zeros(1,scatterindices(2)-scatterindices(1));
    oneuninfect = zeros(1,scatterindices(6)-scatterindices(5));
    oneinfecttime = zeros(1,scatterindices(2)-scatterindices(1));
    oneuninfecttime = zeros(1,scatterindices(6)-scatterindices(5));
    twoinfect = zeros(1,scatterindices(10)-scatterindices(9));
    twouninfect = zeros(1,scatterindices(14)-scatterindices(13));
    twoinfecttime = zeros(1,scatterindices(10)-scatterindices(9));
    twouninfecttime = zeros(1,scatterindices(14)-scatterindices(13));
%nmda stuff
nPoneRAT = cell([1,sweepfileindex]);
nPoneRATtime = cell([1,sweepfileindex]);
nPtwoRAT = cell([1,sweepfileindex]);
nPtwoRATtime = cell([1,sweepfileindex]);
    noneinfect = zeros(1,scatterindices(4)-scatterindices(3));
    noneuninfect = zeros(1,scatterindices(8)-scatterindices(7));
    noneinfecttime = zeros(1,scatterindices(4)-scatterindices(3));
    noneuninfecttime = zeros(1,scatterindices(8)-scatterindices(7));
    ntwoinfect = zeros(1,scatterindices(12)-scatterindices(11));
    ntwouninfect = zeros(1,scatterindices(16)-scatterindices(15));
    ntwoinfecttime = zeros(1,scatterindices(12)-scatterindices(11));
    ntwouninfecttime = zeros(1,scatterindices(16)-scatterindices(15));

    windowmin = input('lower-bound time?');
    windowmax = input('upper-bound time?');
    windowmin = 5* windowmin +1;
    windowmax = 5* windowmax +1;
[Cone,Ctwo,Cthree,Cfour,Cfive,Csix,Cseven,Ceight]=deal(1,1,1,1,1,1,1,1);
progressbar(0.2)
for i = 1:sweepfileindex
   %reads .txt file for the sweeps
    B = dlmread(char(filenames(i)));
    %%separates time from sweeps
    sweeps = B(:, 2:end);
    time = B(:, 1);
    plot (time, sweeps);
    %lmao, remove semicolon above to see all sweeps together on a single
    %plot
    %% iterating through sweeps and storing stats
    [r,c] = size(sweeps);
    %since it goes by 0.2 sec instead of 1 sec the indexing is off

    % preallocated vectors for speed, otherwise changing vector size 
    matmins = zeros(1,c);
    mattimes = zeros(1,c);
    matmaxs = zeros(1,c);
    mattimesx = zeros(1,c);

    for j = 1:c
        orig = sweeps(:,j);
        %filtering out the noise
        smoothsweep = sgolayfilt(orig, 5, 25);
        %figure
        plot(time, orig, 'b',time, smoothsweep, 'r');
        grid on
        ax = axis;
        axis ([0,200, -250, 250]);
        xlabel('Sampling Time (sconds)');
        ylabel('Current (Amperes)');
        title('Filtering Noisy Sweep');

        [M, I] = min(smoothsweep(windowmin:windowmax));
        [Mx, Ix] = max(smoothsweep(windowmin:windowmax));
        realI = I+windowmin;
        realIx = I+windowmin;
      %stores everything for retrieval 
        matmins(j) = M;
        mattimes(j) = (realI-1)/5;
        matmaxs(j) = Mx;
        mattimesx(j) = (realIx-1)/5;     
        
    end
%% adds data to scatterplot arrays
%ampa
 for q = Cone: Cone+(positions(i,2)-positions(i,1));
    oneinfect(q)= matmins(q);
    oneinfecttime(q)= mattimes(q);
    Cone = Cone+1;
 end
 ctwo=0;
 for q = Ctwo: Ctwo+(positions(i,6)-positions(i,5));
    oneuninfect(q)= matmins(ctwo+positions(i,5));
    oneuninfecttime(q)= mattimes(ctwo+positions(i,5)-1);
    Ctwo = Ctwo+1;
    ctwo=ctwo+1;
 end
 cthree=0;
 for q = Cthree: Cthree+(positions(i,10)-positions(i,9));
    twoinfect(q)= matmins(cthree+positions(i,9));
    twoinfecttime(q)= mattimes(cthree+positions(i,9)-1);
    Cthree = Cthree+1;
    cthree=cthree+1;
 end
 cfour=0;
 for q = Cfour: Cfour+(positions(i,14)-positions(i,13));
    twouninfect(q)= matmins(cfour+positions(i,13));
    twouninfecttime(q)= mattimes(cfour+positions(i,13)-1);
    Cfour = Cfour+1;
    cfour=cfour+1;
 end
   
%nmda
cfive=0;
 for q = Cfive: Cfive+(positions(i,4)-positions(i,3));
    noneinfect(q)= matmaxs(cfive+positions(i,3)-1);
    noneinfecttime(q)= mattimesx(cfive+positions(i,3)-1);
    Cfive = Cfive+1;
    cfive=cfive+1;
 end
 csix=0;
 for q = Csix: Csix+(positions(i,8)-positions(i,7));
    noneuninfect(q)= matmaxs(csix+positions(i,7)-1);
    noneuninfecttime(q)= mattimesx(csix+positions(i,7)-1);
    Csix = Csix+1;
    csix=csix+1;
 end
 cseven=0;
 for q = Cseven: Cseven+(positions(i,12)-positions(i,11));
    ntwoinfect(q)= matmaxs(cseven+positions(i,11)-1);
    ntwoinfecttime(q)= mattimesx(cseven+positions(i,11)-1);
    Cseven = Cseven+1;
    cseven=cseven+1;
 end
 ceight=0;
 for q = Ceight: Ceight+(positions(i,16)-positions(i,15));
    ntwouninfect(q)= matmaxs(ceight+positions(i,15));
    ntwouninfecttime(q)= mattimesx(ceight+positions(i,15));
    Ceight = Ceight+1;
    ceight=ceight+1;
 end
    %% AMPA
    %calculates ratios etc
    %indexing at this point is trivial because you said you are planning on
    %reformating the sweepcount format
    czpomin = mean(matmins(positions(i,1):positions(i,2)));
    devone = std(matmins(positions(i,1):positions(i,2)));
    czpotime = mean(mattimes(positions(i,1):positions(i,2)));
    devtwo = std(mattimes(positions(i,1):positions(i,2)));
    copomin = mean(matmins(positions(i,5):positions(i,6)));
    devthree = std(matmins(positions(i,5):positions(i,6)));
    copotime = mean(mattimes(positions(i,5):positions(i,6)));
    devfour = std(mattimes(positions(i,5):positions(i,6)));
    czptmin = mean(matmins(positions(i,9):positions(i,10)));
    devfive = std(matmins(positions(i,9):positions(i,10)));
    czpttime = mean(mattimes(positions(i,9):positions(i,10)));
    devsix = std(mattimes(positions(i,9):positions(i,10)));
    coptmin = mean(matmins(positions(i,13):positions(i,14)));
    devseven = std(matmins(positions(i,13):positions(i,14)));
    copttime = mean(mattimes(positions(i,13):positions(i,14)));
    deveight = std(mattimes(positions(i,13):positions(i,14)));
    
    AMPAarray = ...
        [czpomin,copomin,czpotime,copotime,czptmin,coptmin,czpttime,copttime;
        devone,devthree,devtwo,devfour,devfive,devseven,devsix,deveight];
    newAMPA = zeros(2,8);
    if infectstatus(i) == 1; %the index in sweepcount column of which is infected has value of 1 then switch czpomin and copomin
        %switch
        for k = 1:2:7
            
            [newAMPA(:,k),newAMPA(:,k+1)] = deal(AMPAarray(:,k+1),AMPAarray(:,k));
            %switches every other column with its adjacent column, thereby effectively switch channels 0 and 1
            [oneinfect,oneuninfect,oneinfecttime,oneuninfecttime,twoinfect,twouninfect,twoinfecttime,twouninfecttime] =...
                deal(oneuninfect,oneinfect,oneuninfecttime,oneinfecttime,twouninfect,twoinfect,twouninfecttime,twoinfecttime);
        end
        
    else
        newAMPA = AMPAarray;
        
    end    
        PoneRAT(i) = ...
            {sprintf(outputstr,newAMPA(1),newAMPA(2),newAMPA(3),newAMPA(4))};
        PoneRATtime(i) = ...
            {sprintf(outputstr,newAMPA(5),newAMPA(6),newAMPA(7),newAMPA(8))};
        PtwoRAT(i) = ...
            {sprintf(outputstr,newAMPA(9),newAMPA(10),newAMPA(11),newAMPA(12))};
        PtwoRATtime(i) = ...
            {sprintf(outputstr,newAMPA(13),newAMPA(14),newAMPA(15),newAMPA(16))};
        %%error propagation
        
    %%NMDA
    czpomax = mean(matmaxs(positions(i,3):positions(i,4)));
    ndevone = std(matmaxs(positions(i,3):positions(i,4)));
    czpotimex = mean(mattimesx(positions(i,3):positions(i,4)));
    ndevtwo = std(mattimesx(positions(i,3):positions(i,4)));
    copomax = mean(matmaxs(positions(i,7):positions(i,8)));
    ndevthree = std(matmaxs(positions(i,7):positions(i,8)));
    copotimex = mean(mattimesx(positions(i,7):positions(i,8)));
    ndevfour = std(mattimesx(positions(i,7):positions(i,8)));
    czptmax = mean(matmaxs(positions(i,11):positions(i,12)));
    ndevfive = std(matmaxs(positions(i,11):positions(i,12)));
    czpttimex = mean(mattimesx(positions(i,11):positions(i,12)));
    ndevsix = std(mattimesx(positions(i,11):positions(i,12)));
    coptmax = mean(matmaxs(positions(i,15):positions(i,16)));
    ndevseven = std(matmaxs(positions(i,15):positions(i,16)));
    copttimex = mean(mattimesx(positions(i,15):positions(i,16)));
    ndeveight = std(mattimesx(positions(i,15):positions(i,16)));
    NMDAarray = ...
        [czpomax,copomax,czpotimex,copotimex,czptmax,coptmax,czpttimex,copttimex;
        ndevone,ndevthree,ndevtwo,ndevfour,ndevfive,ndevseven,ndevsix,ndeveight];
    newNMDA = zeros(2,8);
    if infectstatus(i) == 1; %the index in sweepcount column of which is infected has value of 1 then switch czpomin and copomin
        %switch
        for l = 1:2:7
            
            [newNMDA(:,l),newNMDA(:,l+1)] = deal(NMDAarray(:,l+1),NMDAarray(:,l));
            %switches every other column with its adjacent column, thereby effectively switch channels 0 and 1
            [noneinfect,noneuninfect,noneinfecttime,noneuninfecttime,ntwoinfect,ntwouninfect,ntwoinfecttime,ntwouninfecttime] =...
                deal(noneuninfect,noneinfect,noneuninfecttime,noneinfecttime,ntwouninfect,ntwoinfect,ntwouninfecttime,ntwoinfecttime);
        end
        
    else
        newNMDA = NMDAarray;
        
    end    
        nPoneRAT(i) = ...
            {sprintf(outputstr,newNMDA(1),newNMDA(2),newNMDA(3),newNMDA(4))};
        nPoneRATtime(i) = ...
            {sprintf(outputstr,newNMDA(5),newNMDA(6),newNMDA(7),newNMDA(8))};
        nPtwoRAT(i) = ...
            {sprintf(outputstr,newNMDA(9),newNMDA(10),newNMDA(11),newNMDA(12))};
        nPtwoRATtime(i) = ...
            {sprintf(outputstr,newNMDA(13),newNMDA(14),newNMDA(15),newNMDA(16))};
      %%error propagation
    
end
   
%% Distribution Analysis
infectedone = [oneinfect;oneinfecttime];
uninfectedone = [oneuninfect;oneuninfecttime];
infectedtwo = [twoinfect;twoinfecttime];
uninfectedtwo = [twouninfect;twouninfecttime];
ninfectedone = [noneinfect;noneinfecttime];
nuninfectedone = [noneuninfect;noneuninfecttime];
ninfectedtwo = [ntwoinfect;ntwoinfecttime];
nuninfectedtwo = [ntwouninfect;ntwouninfecttime];

scatter(infectedone(1,:),infectedone(2,:),20,'b','filled')
hold on
scatter(uninfectedone(1,:),uninfectedone(2,:),20,'r','filled')
        axis ([-80,20,50,150]);
        xlabel('Current (A)')
        ylabel('Time (s)')
        title('Infected and Uninfected: Patch One')
        legend ('Infected','uninfected')
hold off
%{
scatter(infectedtwo(1,:),infectedtwo(2,:),20,'b','filled')
hold on
scatter(uninfectedtwo(1,:),uninfectedtwo(2,:),20,'r','filled')
        axis ([-80,20,50,150]);
        xlabel('Current (A)')
        ylabel('Time (s)')
        title('Infected and Uninfected: Patch two')
        legend ('Infected','uninfected')
hold off
%}
[h,p,ci,stats]=ttest2(oneinfect,oneuninfect);
if h==0
fprintf ('Do not reject the null \n')
end
%% exports to an excel sheet
values={PoneRAT',PoneRATtime',PtwoRAT,PtwoRATtime};
headers={'Patch One', 'Patch One Times','Patch Two', 'Patch Two Times'};
xlswrite('exampleout.xlsx',[headers;values]);
%% closes everything so it doesn't fuck up the workspace for other scripts
    progressbar(1)
    clres = fclose('all');
    if clres == 0
        disp('File closed successfully')
    else
        disp('Error closing file')
    end

