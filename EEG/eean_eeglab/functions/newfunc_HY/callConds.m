% callConds: Put every discrete condition into separate folders.
%
% ---Function Arguments---
%     callConds(epoches,BVresultPath)
%
%   Input:
%
%     epoches: Epoch information which contains as cell. Based on the epoch
%              labels, this function will collect the all subjects' 
%              condition data.
%     BVresultPath: The path that BVresult files will be saved. This function 
%                   accesses to each BVresult directories so as to 
%                   make the .set extension files.
%
%   Output:
%     (--): It will make folders that contains all the subjects'
%           conditions separately.
%
% ---Usage---
%       callConds({'S  1,'S  2','S  3'},pwd);
%
% ---Note----
% callConds helps to collect all the subejcts' condition data in separated
% folders. Therefore, it is easy to access to all the same subejcts'
% identical condition.
%
% see also: eegGrandAll

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function callConds(epoches,BVresultPath)
% It needs fileName and epoch from.

cd(BVresultPath) % the directories in which BVresult saved.
now_dir = dir(BVresultPath);
allNames = { now_dir.name }';

con = 1;
for look = 1:length(allNames)
    if ~isempty(regexp(allNames{look},'..._BVresult'))
        pathList{con} = fullfile(BVresultPath,allNames{look});
        con = con+1;
    end
end; clear con;

%% make a folder for saving all data(One epoch).
for epoch = 1:length(epoches)
    mkdir(['EEG_epoch_' epoches{epoch}])
    for numFile = 1:length(pathList)
        copyfile([pathList{numFile} '/*_epoch_' sprintf('%02d',epoch) '.*'],...
            [BVresultPath '/EEG_epoch_' epoches{epoch}]);
    end;
end;