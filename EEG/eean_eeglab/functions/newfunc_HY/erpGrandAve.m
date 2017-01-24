% erpGrandAve: Averaging many subjects' ERP data.
%
% ---Function Arguments---
%     [erpAve,erpTable] = erpGrandAve(dataFolder,setData,epochRange,varargin)
%
%   Input:
%
%     dataFolder: grand_averaged data folder.
%     setData   : The separate grand averaged .set files in cell. Selected 
%                 files will be averaged.
%     epochRange: Time range on the erp data. Averaged result data will be
%                 marked with the time range given by this input.
%     
%     OPTIONAL
%     chanInt : (default:all) channal numbers for analysis. Instead of
%               using all channels, specific channels can be selected. 
%     ChanRej : (default:EOG) Reject channel number. EOG or other channels
%               can be rejected before running analysis. This function will
%               look for EOG channel, if it finds
%     subInt  : (default:all) subject number for analysis. Instead of using
%               all subject, specific subjects can be selected.
%     saveData: (default:0) Saving output data as .csv file. 1: save the
%               data as .csv file. 0: do not save data as file.
%     saveName: (default:erpGA) The erp averaged .csv file name. Put file
%               name then the file will be saved with that name.

%
%   Output:
%     erpAve  : Time sequence is shown with the averaged data conditions. 
%     erpTable: erpAve output as table. 
%
% ---Usage---
%       [erpAve,erpTable] = erpGrandAve('ENG_grand_averaged',...
%                         {'ENG_GrandAve_01.set','ENG_GrandAve_02.set'},...
%                         [-200:800],[1:29],[30],[1,3,5,6,7],[1],...
%                          'erpAve')
%
% ---Note----
% erpGrandAve averages all subject's identical conditions. For example, 8
% subjects' first condtion data will be averaged. Subject selection is not 
% possibel by now, but it will be available soon. Plotting erp signal trend
% is available after the data ran by erpGrandAve function. Output data can
% be saved as mat or .csv file format for users further research.
%
% see also: erpSubjAve

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function [erpAve,T] = erpGrandAve(dataFolder,setData,epochRange,varargin)

% This function average the (all subjects)grand_averaged data. Since
% grand_averaged data contains subject numbers it is convenient to select
% specific subjects and analyze their erp data.
% set data is cell aray {'1.set','2set',...,'n.set'}
% epochRange is the erp range (default is eegInfo.epochRange)
% chanInt is channals that you are intersted in (default is all chans)
% ChanRej is channals that you are goint to reject from the data set.
%   dataFolder = 'ENG_grand_averaged';
%   setData = {'ENG_GrandAve_01.set','ENG_GrandAve_02.set','ENG_GrandAve_03.set','ENG_GrandAve_06.set'}; 
%   epochRange = [-200:600];
%   chanInt = [1:29];
%   chanRej = [30];
%   subInt = [1,2,3,8,9,14,15,17,23];
%   saveData = [1];
%   saveName = 'nice';
%% find the path in which eeg data saved.
if nargin < 4
    error('Not enough input arguments')
end

onePath = pathGuide;
grandPath = fullfile(onePath,dataFolder);
cd(grandPath)

tmp = pop_loadset(setData{1});

%% default setting for optional inputs.
if isempty(varargin)
    for i = 1:size(tmp.data,1)
        if strcmp(EEG.chanlocs(i).labels,'EOG')
            chanRej = i;
        else chanRej = [];
        end
    end
    chanInt  = 1:size(tmp.data,1);
    subInt   = 1:size(tmp.data,3);
    saveData = 0;
    saveName = 'erpGA';
else 

varNum = length(varargin);
    if varNum == 1;
        chanInt = varargin{1};
        for i = 1:size(tmp.data,1)
            if strcmp(EEG.chanlocs(i).labels,'EOG')
            chanRej = i;
            else chanRej = [];
            end
        end
        subInt  = 1:size(tmp.data,3);
        saveData= 0;
        saveName= 'erpGA';
    elseif varNum ==2;
        chanInt = varargin{1};
        chanRej = varargin{2};
        subInt  = 1:size(tmp.data,3);
        saveData= 0;
        saveName= 'erpGA';        
    elseif varNum ==3;
        chanInt = varargin{1};
        chanRej = varargin{2};
        subInt  = varargin{3};
        saveData= 0;
        saveName= 'erpGA';        
    elseif varNum ==4;
        chanInt = varargin{1};
        chanRej = varargin{2};
        subInt  = varargin{3};
        saveData= varargin{4};
        saveName= 'erpGA';           
    elseif varNum ==5;
        chanInt = varargin{1};
        chanRej = varargin{2};
        subInt  = varargin{3};
        saveData= varargin{4};
        saveName= varargin{5};
    end
end


%% Read the grand averaged data
numData = length(setData);
folderName = dataFolder(1:3);
for import = 1:numData
   eegBox{import} = pop_loadset(setData{import});
end
srate = eegBox{1}.srate;
[numChan,numWin,numSub] = size(eegBox{1}.data);
winFrame = (1/srate)*1000;

%% EOG or fields rejection.
if ~isempty(chanRej)
    for eeg = 1:numData
        eegBox{eeg}.data(chanRej,:,:) = [];
    end
end

%% averaging each column
timeSequence = epochRange(1):winFrame:epochRange(end);
timeSequence(end) = [];
cond = timeSequence;
condition{1} = '';

mean_value = (length(chanInt) * length(subInt));

%%
for eeg = 1:numData
    for col = 1:numWin
        cond(eeg+1,col) = sum(sum(eegBox{eeg}.data(chanInt,col,:)))./mean_value;
    end
    condition{eeg+1} = setData{eeg}(end-5:end-4);
end

erpAve = cond;
%% make a table

subject = repmat(folderName,numData+1,1);
condition = condition';
T = table(subject,condition,cond);

if saveData == 1;
    writetable(T,sprintf('%s.csv',saveName));
end

cd(onePath)
