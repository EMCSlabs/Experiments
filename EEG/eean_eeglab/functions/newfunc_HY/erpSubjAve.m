% erpSubjAve: Averaging a single subject's ERP data.
%
% ---Function Arguments---
%     [erpAve,T] = erpSubjAve(dataFolder,setData,epochRange,varargin)
%
%   Input:
%
%     dataFolder: *_BVresult data folder.
%     setData   : The separately averaged .set files in cell. if
%                 epoch_averaged folder was created, selected setData will 
%                 be choosen in that folder.
%     epochRange: Time range on the erp data. Averaged result data will be
%                 marked with the time range given by this input.
%     
%     OPTIONAL
%     chanInt : (default:all) channal numbers for analysis. Instead of
%               using all channels, specific channels can be selected. 
%     ChanRej : (default:EOG) Reject channel number. EOG or other channels
%               can be rejected before running analysis. This function will
%               look for EOG channel, if it finds
%     subInt  : (default:5) subject number for analysis. Instead of using
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
%       [erpAve,erpTable] = erpSubjAve('E01_BVresult',...
%                         {'E01_epoch_01.set','ENG_GrandAve_02.set'},...
%                         [-200:800],[6,9,11],[30],[1,3,5,6,7],[1],...
%                          'erpAve')
%
% ---Note----
% erpSubjAve averages a single subject's erp data. It is different from
% erpGrandAve because users are able to access to individual erp data for
% sophisticated analysis. On the one hand, whole averaged data by erpGrandAve
% function are useful to identify each conditions' signal trend. On the
% other hand, separatly averaged data by erpSubjAve function are convenient
% to study becuase accessibility to each signal data is much easier. 

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function [erpAve,erpTable] = erpSubjAve(dataFolder,setData,epochRange,varargin)
    
if nargin < 3
    help(erpSubjAve);
end

%% go to the folder
onePath = pathGuide;
grandPath = dataFolder;
cd(grandPath)

% make epoch_averaged data if this folder wasn't created
global eegInfo

folderName = dataFolder(1:3);
if ~(exist('epoch_averaged') == 7)
    eegGrandOne(folderName,eegInfo.epoch)
    cd(grandPath)
end


% Go to the data directory.
cd('epoch_averaged')
tmp = pop_loadset(setData{1});
numData = length(setData);

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
%        subInt  = 1:size(tmp.data,3);
        saveData= 0;
        saveName= 'erpGA';
    elseif varNum ==2;
        chanInt = varargin{1};
        chanRej = varargin{2};
        saveData= 0;
        saveName= 'erpGA';        
    elseif varNum ==3;
        chanInt = varargin{1};
        chanRej = varargin{2};
        saveData= varargin{3};
        saveName= 'erpGA';        
    elseif varNum ==4;
        chanInt = varargin{1};
        chanRej = varargin{2};
        saveData= varargin{3};
        saveName= varargin{4};           
    end
end

for import = 1:numData
   eegBox{import} = pop_loadset(setData{import});
end

% average the data.
srate = eegBox{1}.srate;
[numChan,numWin,numSub] = size(eegBox{1}.data);
winFrame = (1/srate)*1000;

%% EOG or fields rejection.
for eeg = 1:numData
    eegBox{eeg}.data(chanRej,:,:) = [];
end

%% 
timeSequence = epochRange(1):winFrame:epochRange(end);
timeSequence(end) = [];
cond = timeSequence;
condition{1} = '';
mean_value = length(chanInt);
%%
for eeg = 1:numData
    for col = 1:numWin
        cond(eeg+1,col) = sum(sum(eegBox{eeg}.data(chanInt,col)))./mean_value;
    end
    condition{eeg+1} = setData{eeg}(end-5:end-4);
end

erpAve = cond;

%% make a table

subject = repmat(folderName,numData+1,1);
condition = condition';
erpTable = table(subject,condition,cond);

if saveData == 1;
    writetable(erpTable,sprintf('%s.csv',saveName));
end
cd(onePath)

fprintf('\nProcess finished.\n')