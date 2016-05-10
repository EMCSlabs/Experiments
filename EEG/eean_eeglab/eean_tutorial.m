% eean tutorial (EEg ANalysis)
%
% This eean tutorial describes the EEG data analysis procedure.
% Please run the script line by line and try to understand what those lines
% do. This tutorial shows one typical way to analyse EEG data. Therefore,
% find more useful function information in 'eean_eeglab /functions/ 
% newfunc_HY', or 'README.txt'.

%                                                    Author: Hyungwon Yang
%                                                               2015.12.01
%                                                                 EMCS lab

%% Path setting
% navigate to the eean folder and run this part.

addpath(genpath(pwd));

%% eegInfo structure.

%%%%%  ENGLISH  %%%%%

%%%%% Data Information %%%%%%%%%
clear;clc;
eegInfo.fileName = ['E01']; 
eegInfo.title = ['ENG'];
eegInfo.dataPath =['ENGLISH_EEG']; 
eegInfo.baPath =['ENGLISH_BA']; 
eegInfo.subjectName = [1,2,3,8,14,15,17];

eegInfo.sampling = [250];
eegInfo.filter = [0.1 30 4];
eegInfo.reReference = [31 32];
eegInfo.chanInt = [1:30];

%%%%% conditions %%%%%
eegInfo.epoch ={'S  1','S  2','S  3','S  4','S  5','S  6','S  7','S  8','S  9'};

eegInfo.epochInt = {'S  1','S  2','S  3','S  4'}; % main stimuli
eegInfo.epochCut = [70]; % xx percent is the threshold.
eegInfo.epochTotal = [120]; % total number of interesting epoches.
eegInfo.epochRange = [-0.18 0.62];
eegInfo.baseRange = [-180 20];

%%%%% Behavioral Test %%%%%
eegInfo.BTName = ['English_priming-01.txt']; 
eegInfo.trialNum = [320]; % The number of epoches.

eegInfo.BTSelect = [0]; % 0 - incorrect / 1 - correct
eegInfo.BTminmax = [300 1500]; % min and max time values
eegInfo.BTsaveFile = [0]; % please check 'eegBA.m' / '0' is preferred.
eegInfo.BTbooster = [5]; % please check 'eegBA.m' / '5' is preferred.
eegInfo.reject = [-100,100,-0.18,0.616];

%%%%% Gratton Method %%%%%
eegInfo.gratton.tell = [1];
eegInfo.gratton.eogChan = [30];
eegInfo.gratton.blinkWin = [1000];
eegInfo.gratton.blinkVolt = [200];


%%%%% ICA %%%%%
eegInfo.ica.tell = [0]; % check '1' if you want to run ICA.
eegInfo.ica.reject = [-80 80 -0.18 0.616];
eegInfo.ica.trend = [50 0.05];
eegInfo.ica.prob = [4 4];
eegInfo.ica.kurt = [5 5];

%%%%% erp Analysis %%%%%
eegInfo.erpSetData = ...
    {'ENG_GrandAve_01.set','ENG_GrandAve_02.set',...
    'ENG_GrandAve_03.set','ENG_GrandAve_04.set'}; % analyzing data
eegInfo.erpTimeRange = [-200:600];
eegInfo.erpChanInt = [1:29]; % erp channels (30 is eog now)
eegInfo.erpChanRej = [30]; % 30 is eog channel
eegInfo.erpSave = [0]; % choose '1' then it will save the text result file.
eegInfo.erpSubInt = [1:7]; % all subjects or specific subject. high and low level.

%% Data preprocessing

% Baisc analysis
for i = eegInfo.subjectName
    eegInfo.fileName = [sprintf('E%02d',i)];
    eegInfo.BTName = [sprintf('English_priming-%02d.txt',i)];
    eegResult(eegInfo)
end

% %% Join conditions
% % New epoch names will be added at the end.
% joint = {[2,3]}; % the number of join conditions
% eegInfo.epoch = joinConds(eegInfo.fileName,eegInfo.epoch,...
% length(eegInfo,subjectName),joint);


%% Reject the data and check which subject data have been rejected.

for i = eegInfo.subjectName
    eegInfo.fileName = [sprintf('E%02d',i)];
    [passEpoch{i},percent(i)] = epochCheck(eegInfo.fileName,eegInfo.epoch,...
                     eegInfo.epochInt,eegInfo.epochTotal,eegInfo.epochCut);
end
    
% rejected data checking
for i= 1:length(passEpoch)
    disp([num2str(i) 'subject'])
    disp(passEpoch{i});
end
percent


%% Grand average for each subject
% output will be saved in epoch_averaged folder in BVresult.

for i = 1:length(eegInfo.subjectName)
    eegInfo.fileName = sprintf('E%02d',eegInfo.subjectName(i));
    eegGrandOne(eegInfo.fileName,eegInfo.epoch);
end

%% Grand average for all subjects.
% It will average all subejct data.
eegInfo.title = 'ENG';
eegGrandAll(eegInfo.epoch,eegInfo.title)

%% ERP data analysis: Averaging interesting channels for one subject.

% ERP channel Interest

% All channel : [1  : 29]
% Right Front : [4,21,25] Frontal lobe
% Left Front  : [3,20,24] Frontal lobe
% Right Center: [6,23,27] Parietal lobe
% Left Center : [5,22,26] Parietal lobe
% Right Back  : [8,10,16] Occipital lobe
% Left Back   : [7, 9,15] Occipital lobe

%onePath = pathGuide;
eegInfo.erpChanInt = {[1:29],[4,21,25],[3,20,24],[6,23,27],[5,22,26],...
       [8,10,16],[7,9,15]};
eegInfo.erpSave = [1];

con = 1;
for i = eegInfo.subjectName % specify the subjects to be analysed.
    dataFolder = sprintf('E%02d_BVresult',i);
    eegInfo.erpSetData = {sprintf('E%02d_averaged_01.set',i),...
        sprintf('E%02d_averaged_02.set',i),sprintf('E%02d_averaged_03.set',i)...
        sprintf('E%02d_averaged_04.set',i)};
    for j = 1:length(eegInfo.erpChanInt)
    saveName = sprintf('E%02d_epoch_Ave_%02d',i,j);
    [~,T] = erpSubjAve(dataFolder,eegInfo.erpSetData,eegInfo.erpTimeRange,...
    eegInfo.erpChanInt{j},eegInfo.erpChanRej,...
    eegInfo.erpSave,saveName);
    comb{j} = T;
    end
    stack{con} = comb;
    con = con+1;
end
clear con;
%% Save ERP data for statistical analysis.

[erpData] = erpSave(stack);

%% ERP data analysis: Averaging interesting channels for many subject.

dataFolder = 'ENG_grand_averaged';
eegInfo.erpSetData = {'ENG_GrandAve_01.set','ENG_GrandAve_02.set',...
        'ENG_GrandAve_03.set','ENG_GrandAve_04.set'};
eegInfo.erpChanInt = {[1:29],[4,21,25],[3,20,24],[6,23,27],[5,22,26],...
       [8,10,16],[7,9,15]};
eegInfo.erpSubInt = [1:7]; %how many subjects you have?
eegInfo.erpSave = [1];

for i = 1:length(eegInfo.erpChanInt)
    saveName = sprintf('ENG_GrandAve_Ave_%02d',i);
    [erpAve{i},T] = erpGrandAve(dataFolder,eegInfo.erpSetData,eegInfo.erpTimeRange,...
    eegInfo.erpChanInt{i},eegInfo.erpChanRej,eegInfo.erpSubInt,eegInfo.erpSave,...
    saveName);
end

%% erpPlot
% all lesions
condView = [1,2,3,4];
erpPlot(eegInfo.erpTimeRange,erpAve{1},condView)

%% erpPlot
% 7 brain lesions
condView = [1,2,3,4];
for i = 1:length(eegInfo.erpChanInt)
    erpPlot(eegInfo.erpTimeRange,erpAve{i},condView)
    close all
end
