function eegInfo = calleegInfo

global eegInfo

clear,clc;
eegInfo.fileName = ['K01']; % K01
eegInfo.title = ['KOR'];% KOR
eegInfo.dataPath =['KOREAN_eeg']; % kor_eeg
eegInfo.baPath =['KOREAN_BA']; % kor_BA
eegInfo.numSubject = [24];

eegInfo.sampling = [250];
eegInfo.filter = [0.1 30 4];
eegInfo.reReference = [31 32];
eegInfo.chanInt = [1:30];
%%%%% CHECK %%%%%
eegInfo.epoch =...
    {'S  1','S  2','S  3','S  4','S  5','S  6','S  7','S  8','S  9',...
     'S 10','S 11','S 12'}; % for korean trial

eegInfo.epochInt = {'S  1','S 13','S 14','S  6'}; % main stimuli
eegInfo.epochCut = [70]; % xx percent is the threshold.
eegInfo.epochTotal = [160]; % total number of interesting epoches.
eegInfo.epochRange = [-0.18 0.62];
eegInfo.baseRange = [-180 20];
%%%%% CHECK %%%%%
eegInfo.BTName = ['Korean_priming-01.txt']; % Korean_priming-01.txt
eegInfo.trialNum = [400]; % The number of epoches. % kor: 400

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

%%%%% erp Aanlysis %%%%%
eegInfo.erpSetData = ...
    {'KOR_GrandAve_01.set','KOR_GrandAve_013.set','KOR_GrandAve_14.set','KOR_GrandAve_06.set'}; % analyzing data
eegInfo.erpTimeRange = [-200:600];
eegInfo.erpChanInt = [1:29]; % erp channels (30 is eog now)
eegInfo.erpChanRej = [30]; % 30 is eog channel
eegInfo.erpSave = [0]; % choose '1' then it will save the text result file.
eegInfo.erpSubInt = [1:18]; % all subjects or specific subject. high and low level.

% ??? ???: f4,  fc2, fc6 = 4, 21, 25
% ??? ???: f3, fc1, fc5  = 3, 20, 24
% ??? ???: c4,  cp2, cp6 = 6, 23, 27
% ??? ???: c3,  cp1, cp5 = 5, 22, 26
% ??? ???: p4,  O2,  p8  = 8, 10, 16
% ??? ???: p3,  O1,  p7  = 7, 9,  15
%%%%%%%%%%%%%%%%%%%