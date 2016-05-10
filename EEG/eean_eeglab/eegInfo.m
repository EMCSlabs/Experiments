% eegInfo: eegInfo generator.
%
% ---Instruction---
% eegInfo constructs the basic information to start data analysis.
% Selecting particular methods or manipulating filtering threshold or time
% winodws are available. But most importantly, users should know what each
% eegInfo components are doing. Find eean_tutorial for more information.
%
% ---Usage---
% type eegInfo in the command line.
%

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function output = eegInfo

%%%%%  ENGLISH  %%%%%

%%%%% Data Information %%%%%%%%%
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

output = eegInfo;
