% epochCheck: checking epochs and rejecting the abnormal data.
%
% ---Function Arguments---
%     [passEpoch,percent] = epochCheck(fileName,epoches,epochInt,...
%                                      epochTotal,epochCut)
%
%   Input:
%
%     fileName: The folder in which a single subject's condition data stored.
%               Analysed data will be saved as 'fileName'_BVresult. This
%               name format was set for users convenience and easy
%               recognition of the folders. 
%     epoches:  Epoch information which contains as cell. Based on the epoch
%               labels, this function will collect the all subjects' 
%               condition data.
%     epochInt: Interesting epoch conditions. User picked epoches will be
%               calculated and checked whether those number of saved 
%               conditions are suficient for analysis. Otherwise, the
%               function will discard the dataset.
%     epochTotal : The total number of interesting epoches. epochTotal will
%                  be to the number of epochInt alive. 
%                  (i.e., totalNumber(epochInt) / epochTotal)
%     epochCut : The data rejection threshold. If the portion of the
%                number of main epoches are not over the epochCut, then
%                the data will be discarded.
%
%   Output:
%     passEpoch: The saved number of each condition. This shows the saved
%                epoch numbers in each condition that have not been 
%                rejected from eye-movement correction, ICA and so on.
%     percent: The percentage represents the proportion of interesting 
%              epoches that saved. This percent will be compared with
%              epochCut and the data below it will be discarded.
%
% ---Usage---
%       [passEpoch,percent] = epochCheck('E01',{'S  1,'S  2','S  3'},...
%               {'S  1','S  2'},80,65)
%                           
%
% ---Note----
% Once the raw eeg data preprocessed by eegResult, Bvresult should be
% checked and rejected if the remaining number of the epoch data in BV result 
% folder is not sufficient to be used for analysis. epochCut input will be
% compared with the each percent output from dataset. Then the dataset will
% be rejected or remained based on the epochCut value.

%
% see also: 

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function [passEpoch,percent] = epochCheck(fileName,epoches,epochInt,...
                                          epochTotal,epochCut)

%% set the directories
onePath = pathGuide;
dataDir = fullfile(onePath,[fileName '_BVresult']);

%% extract eeg_result data.
directory = dir(onePath);
allNames = {directory.name}';

for name = 1:length(allNames)
    if ~isempty(regexp(allNames{name},[fileName '_BVresult']))
        cd(dataDir)
        for epoch = 1:length(epoches)
        EEG = pop_loadset(sprintf('%s_epoch_%02d.set',fileName,epoch));
        WEpoch(epoch) = length(EEG.epoch);
        end
    end
end

%% Get the Intresting and Non-interesting epoch numbers
int = zeros(1,length(WEpoch));
notInt = zeros(1,length(WEpoch));

for num = 1:length(epoches)
    for find = 1:length(epochInt)
        if regexp(epoches{num},epochInt{find})
            int(num) = WEpoch(num); 
            break;
        end
    end
    if int(num) == 0;
        notInt(num) = WEpoch(num);end;
end

%% Remove the directory if it dose not satisfy threshold.
totalNum = floor((sum(int)/epochTotal)*100);
if totalNum < epochCut
    cd(onePath)
    rmdir([fileName '_BVresult'],'s');
end

cd(onePath)
    
passEpoch = WEpoch;
percent = totalNum; % total not rejected epoch number.

