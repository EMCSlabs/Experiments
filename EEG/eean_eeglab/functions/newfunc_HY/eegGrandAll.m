% eegGrandAll: Averaging all subjects' epoch data.
%
% ---Function Arguments---
%     eegGrandAll(epoches,title)
%
%   Input:
%
%     epoches: Epoch information contained in cell. Based on the epoch
%              labels, this function will collect the all subjects' 
%              condition data.
%     title: The folder front title name. This mainly used for name
%            tagging.
%
%   Output:
%     (--): It will make a folder that contains epoch averaged data.
%
% ---Usage---
%       eegGrandAll({'S  1,'S  2','S  3'},'ENG')
%
% ---Note----
% Whole subjects' every condition epoch data will be averaged through this
% function which means each .set data contained every subject's averaged 
% signals. The researchers might not use this function for running 
% statistics, but plot the erp signals with this data and try to figure out
% the signal tendency of each condition.
%
% see also: erpPlot

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab

function eegGrandAll(epoches,title)
% it needs fileName, epoch, title from eegInfo.
% It grand averages all the data which includes in BVresult folders.

%% save grand averaged epochs.
% find the path in which eeg data saved.
onePath = pathGuide;

%% call all the conditions separately.
callConds(epoches,pwd);


%% grand averaging and saving: all subject, one epoch

mkdir([title '_grand_averaged']);

for epoch = 1:length(epoches)
    cd(fullfile(onePath,['EEG_epoch_' epoches{epoch}]))
    cd([onePath '/EEG_epoch_' epoches{epoch}])
    epoch_dir = dir(pwd);
    epochNames = {epoch_dir.name};
    con = 1;
    for name = 1:length(epochNames)
        if ~isempty(regexp(epochNames{name},'.set'));
            takeName{con} = epochNames{name};
            con = con+1;
        end
    end
    [averaged,~] = pop_grandaverage(takeName);
    pop_saveset(averaged,sprintf('%s_GrandAve_%02d',title,epoch));
    movefile(sprintf('%s_GrandAve_%02d.*',title,epoch),...
        fullfile(onePath,[title '_grand_averaged']))
end

cd(onePath)

% remove epoch gathered directories. (have to set this as an option)
for i = 1:length(epoches)
    rmdir(['EEG_epoch_' epoches{i}],'s')
end




    