%% start on a clean slate
clear all; clc; close all;
%opens sweepcount excel file

[filename, pathname, ~] = uigetfile({'*.xls*';'*.*'},'Select File');
 
[A,B,C] = xlsread(filename);
disp('excel file imported')

%%

Cond = A(:,end);

A = A(:,1:16);

names = B(2:end,1);

filenames = strcat(names, '.txt');

positions = A(:,16);

positions = positions - 1;

[row,col] = size(positions);

infectstatus = A(:,21);

newpositions = zeros(row,col);



%% IMPORT DATA
C={};
for nn = 1:numel(filenames)

    opts = detectImportOptions(filenames{nn});
    opts = setvartype(opts,{opts.VariableNames{1:end}},'double');
    T = readtable(filenames{nn},opts);
    C{nn} = table2array(T);

end



plot(C{1}(:,1), C{1}(:,2:end))


for nn = 1:2:size(A,2)

    Y = C{1}( :, A(1,nn) : A(1,nn+1)  );

    X = repmat(C{1}(:,1), 1, size(Y,2));

    plot( X , Y , 'Color', rand(1,3))
    hold on

end



for nn = 1:2:size(A,2)

    Y = C{1}( :, A(1,nn) : A(1,nn+1)  );

    N = size(Y,2);

    Ymu = mean(Y,2);

    Ysd = std(Y,[],2);

    SEM = Ysd / sqrt(N);

    X = C{1}(:,1);

    c = rand(1,3);
    plot( X , Ymu , 'LineWidth',2, 'Color', c)
    hold on
    %errorbar(X(500:10:end),Ymu(500:10:end),SEM(500:10:end), 'LineWidth',2, 'Color', c)
    %hold on

end















%% Gets names of the sweep .txt files to open and stores relevant channel and patch indices in positions

% get the sweepcounts for each channel and patch



for t = 1:size(infectstatus)
    if infectstatus(t) == 1; %the index in sweepcount column of which is infected has value of 1 then switch czpomin and copomin
        %switch
        for m = 1:4
            
            [newpositions(t,m),newpositions(t,m+4)] = deal(positions(t,m+4),positions(t,m));
            
        end
        for m = 9:12
            
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
        fullinfect1 = double.empty(0,0);
        fulluninfect1 = double.empty(0,0);
        fullinfect2 = double.empty(0,0);
        fulluninfect2 = double.empty(0,0);
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
    plot (time, sweeps)
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
        plot(time, orig, 'b',time, smoothsweep, 'r')
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
        
        if j>=newpositions(i,1) && j<=newpositions(i,2)
            fullinfect1 = [fullinfect1, orig];
        elseif j>=newpositions(i,5) && j<=newpositions(i,6)
            fulluninfect1 = [fulluninfect1, orig];
        elseif j>=newpositions(i,9) && j<=newpositions(i,10)
            fullinfect2 = [fullinfect2, orig];
        elseif j>=newpositions(i,13) && j<=newpositions(i,14)
            fulluninfect2 = [fulluninfect2, orig];
        end
            
        
    end
%% adds data to scatterplot arrays
%ampa
 for q = Cone: Cone+(newpositions(i,2)-newpositions(i,1));
    oneinfect(q)= matmins(q);
    oneinfecttime(q)= mattimes(q);
    Cone = Cone+1;
 end
 ctwo=0;
 for q = Ctwo: Ctwo+(newpositions(i,6)-newpositions(i,5));
    oneuninfect(q)= matmins(ctwo+newpositions(i,5));
    oneuninfecttime(q)= mattimes(ctwo+newpositions(i,5)-1);
    Ctwo = Ctwo+1;
    ctwo=ctwo+1;
 end
 cthree=0;
 for q = Cthree: Cthree+(newpositions(i,10)-newpositions(i,9));
    twoinfect(q)= matmins(cthree+newpositions(i,9));
    twoinfecttime(q)= mattimes(cthree+newpositions(i,9)-1);
    Cthree = Cthree+1;
    cthree=cthree+1;
 end
 cfour=0;
 for q = Cfour: Cfour+(newpositions(i,14)-newpositions(i,13));
    twouninfect(q)= matmins(cfour+newpositions(i,13));
    twouninfecttime(q)= mattimes(cfour+newpositions(i,13)-1);
    Cfour = Cfour+1;
    cfour=cfour+1;
 end
   
%nmda
cfive=0;
 for q = Cfive: Cfive+(newpositions(i,4)-newpositions(i,3));
    noneinfect(q)= matmaxs(cfive+newpositions(i,3)-1);
    noneinfecttime(q)= mattimesx(cfive+newpositions(i,3)-1);
    Cfive = Cfive+1;
    cfive=cfive+1;
 end
 csix=0;
 for q = Csix: Csix+(newpositions(i,8)-newpositions(i,7));
    noneuninfect(q)= matmaxs(csix+newpositions(i,7)-1);
    noneuninfecttime(q)= mattimesx(csix+newpositions(i,7)-1);
    Csix = Csix+1;
    csix=csix+1;
 end
 cseven=0;
 for q = Cseven: Cseven+(newpositions(i,12)-newpositions(i,11));
    ntwoinfect(q)= matmaxs(cseven+newpositions(i,11)-1);
    ntwoinfecttime(q)= mattimesx(cseven+newpositions(i,11)-1);
    Cseven = Cseven+1;
    cseven=cseven+1;
 end
 ceight=0;
 for q = Ceight: Ceight+(newpositions(i,16)-newpositions(i,15));
    ntwouninfect(q)= matmaxs(ceight+newpositions(i,15));
    ntwouninfecttime(q)= mattimesx(ceight+newpositions(i,15));
    Ceight = Ceight+1;
    ceight=ceight+1;
 end
    %% AMPA
    %calculates ratios etc
    %indexing at this point is trivial because you said you are planning on
    %reformating the sweepcount format
    czpomin = mean(matmins(newpositions(i,1):newpositions(i,2)));
    devone = std(matmins(newpositions(i,1):newpositions(i,2)));
    czpotime = mean(mattimes(newpositions(i,1):newpositions(i,2)));
    devtwo = std(mattimes(newpositions(i,1):newpositions(i,2)));
    copomin = mean(matmins(newpositions(i,5):newpositions(i,6)));
    devthree = std(matmins(newpositions(i,5):newpositions(i,6)));
    copotime = mean(mattimes(newpositions(i,5):newpositions(i,6)));
    devfour = std(mattimes(newpositions(i,5):newpositions(i,6)));
    czptmin = mean(matmins(newpositions(i,9):newpositions(i,10)));
    devfive = std(matmins(newpositions(i,9):newpositions(i,10)));
    czpttime = mean(mattimes(newpositions(i,9):newpositions(i,10)));
    devsix = std(mattimes(newpositions(i,9):newpositions(i,10)));
    coptmin = mean(matmins(newpositions(i,13):newpositions(i,14)));
    devseven = std(matmins(newpositions(i,13):newpositions(i,14)));
    copttime = mean(mattimes(newpositions(i,13):newpositions(i,14)));
    deveight = std(mattimes(newpositions(i,13):newpositions(i,14)));
    
    AMPAarray = ...
        [czpomin,copomin,czpotime,copotime,czptmin,coptmin,czpttime,copttime;
        devone,devthree,devtwo,devfour,devfive,devseven,devsix,deveight];
 
        PoneRAT(i) = ...
            {sprintf(outputstr,AMPAarray(1),AMPAarray(2),AMPAarray(3),AMPAarray(4))};
        PoneRATtime(i) = ...
            {sprintf(outputstr,AMPAarray(5),AMPAarray(6),AMPAarray(7),AMPAarray(8))};
        PtwoRAT(i) = ...
            {sprintf(outputstr,AMPAarray(9),AMPAarray(10),AMPAarray(11),AMPAarray(12))};
        PtwoRATtime(i) = ...
            {sprintf(outputstr,AMPAarray(13),AMPAarray(14),AMPAarray(15),AMPAarray(16))};
        %%error propagation
        
    %%NMDA
    czpomax = mean(matmaxs(newpositions(i,3):newpositions(i,4)));
    ndevone = std(matmaxs(newpositions(i,3):newpositions(i,4)));
    czpotimex = mean(mattimesx(newpositions(i,3):newpositions(i,4)));
    ndevtwo = std(mattimesx(newpositions(i,3):newpositions(i,4)));
    copomax = mean(matmaxs(newpositions(i,7):newpositions(i,8)));
    ndevthree = std(matmaxs(newpositions(i,7):newpositions(i,8)));
    copotimex = mean(mattimesx(newpositions(i,7):newpositions(i,8)));
    ndevfour = std(mattimesx(newpositions(i,7):newpositions(i,8)));
    czptmax = mean(matmaxs(newpositions(i,11):newpositions(i,12)));
    ndevfive = std(matmaxs(newpositions(i,11):newpositions(i,12)));
    czpttimex = mean(mattimesx(newpositions(i,11):newpositions(i,12)));
    ndevsix = std(mattimesx(newpositions(i,11):newpositions(i,12)));
    coptmax = mean(matmaxs(newpositions(i,15):newpositions(i,16)));
    ndevseven = std(matmaxs(newpositions(i,15):newpositions(i,16)));
    copttimex = mean(mattimesx(newpositions(i,15):newpositions(i,16)));
    ndeveight = std(mattimesx(newpositions(i,15):newpositions(i,16)));
    NMDAarray = ...
        [czpomax,copomax,czpotimex,copotimex,czptmax,coptmax,czpttimex,copttimex;
        ndevone,ndevthree,ndevtwo,ndevfour,ndevfive,ndevseven,ndevsix,ndeveight];
  
        nPoneRAT(i) = ...
            {sprintf(outputstr,NMDAarray(1),NMDAarray(2),NMDAarray(3),NMDAarray(4))};
        nPoneRATtime(i) = ...
            {sprintf(outputstr,NMDAarray(5),NMDAarray(6),NMDAarray(7),NMDAarray(8))};
        nPtwoRAT(i) = ...
            {sprintf(outputstr,NMDAarray(9),NMDAarray(10),NMDAarray(11),NMDAarray(12))};
        nPtwoRATtime(i) = ...
            {sprintf(outputstr,NMDAarray(13),NMDAarray(14),NMDAarray(15),NMDAarray(16))};
     
end
   idone = find(oneinfect>0);
   idtwo = find(oneuninfect>0);
   idthree = find(twoinfect>0);
   idfour = find(twouninfect>0);
   oneinfect(idone) = [];
   oneinfecttime(idone) = [];
   oneuninfect(idtwo) = [];
   oneuninfecttime(idtwo) = [];
   twoinfect(idthree) = [];
   twoinfecttime(idthree) = [];
   twouninfect(idfour) = [];
   twouninfecttime(idfour) = [];
%% Distribution Analysis
infectedone = [oneinfect;oneinfecttime];
uninfectedone = [oneuninfect;oneuninfecttime];
infectedtwo = [twoinfect;twoinfecttime];
uninfectedtwo = [twouninfect;twouninfecttime];
ninfectedone = [noneinfect;noneinfecttime];
nuninfectedone = [noneuninfect;noneuninfecttime];
ninfectedtwo = [ntwoinfect;ntwoinfecttime];
nuninfectedtwo = [ntwouninfect;ntwouninfecttime];

scatter(infectedone(2,:),infectedone(1,:),20,'b','filled')
hold on
scatter(uninfectedone(2,:),uninfectedone(1,:),20,'r','filled')
        axis ([-80,20,50,150]);
        xlabel('Current (A)')
        ylabel('Time (s)')
        title('Infected and Uninfected: Patch One')
        legend ('Infected','uninfected')
hold off
%{
scatter(infectedtwo(2,:),infectedtwo(1,:),20,'b','filled')
hold on
scatter(uninfectedtwo(2,:),uninfectedtwo(1,:),20,'r','filled')
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
    else
    fprintf ('reject the null \n')
end
%% exports patch one to an excel sheet
[~,cOne]= size(oneinfect);
[~,cTwo]= size(oneuninfect);
numrows=cOne+cTwo;
Population = cell(numrows,1,1);
sampleid=1:numrows;
sampleid = sampleid';
for b = 1:cOne
    Population(b) = {'infected'};
end
for v = cOne+1:numrows
   Population(v) = {'uninfected'}; 
end
allpeaks = [oneinfect';oneuninfect'];
alltimes = [oneinfecttime';oneuninfecttime'];
values=[Population,num2cell(sampleid),num2cell(allpeaks),num2cell(alltimes)];
headers={'Population', 'Sample ID','Current', 'Time'};
xlswrite('exampleout2.xlsx',[headers;values]);
%% exports patch two to an excel sheet
[~,cOne]= size(twoinfect);
[~,cTwo]= size(twouninfect);
numrows=cOne+cTwo;
Population = cell(numrows,1,1);
sampleid=1:numrows;
sampleid = sampleid';
for b = 1:cOne
    Population(b) = {'infected'};
end
for v = cOne+1:numrows
   Population(v) = {'uninfected'}; 
end
allpeaks = [twoinfect';twouninfect'];
alltimes = [twoinfecttime';twouninfecttime'];
values=[Population,num2cell(sampleid),num2cell(allpeaks),num2cell(alltimes)];
headers={'Population', 'Sample ID','Current', 'Time'};
xlswrite('exampleout2.xlsx',[headers;values],2);
%% Finds literally the average curves using the average value at each time for infected vs uninfected in each patch
%return column vector of mean values of each row of array of sweeps, giving
%avg at each time
avginfect1 = mean(fullinfect1,2);
avguninfect1 = mean(fulluninfect1,2);
avginfect2 = mean(fullinfect2,2);
avguninfect2 = mean(fulluninfect2,2);
%%plots average curves
plot(time,avginfect1','-r','LineWidth',2)
hold on
plot(time,avguninfect1,'-b', 'LineWidth',2)
hold off
grid
legend('Patch One Infected','Patch One Uninfected')

%% closes everything so it doesn't fuck up the workspace for other scripts
    progressbar(1)
    clres = fclose('all');
    if clres == 0
        disp('File closed successfully')
    else
        disp('Error closing file')
    end

