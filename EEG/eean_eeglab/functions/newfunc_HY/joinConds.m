% joinConds: Join one or more conditions.
%
% ---Function Arguments---
%     [newEpoch] = joinConds(fileName,epoches,numSubject,joinChans,dimset)
%
%   Input:
%
%     fileName: Initial marked name on the data.
%     epoches : Epoch information contained in cell. Joined epoches will be
%               attached at the end of the epoches with a new number label.
%     numSubject : Total number of subejcts.
%     joinChans  : Joining channels. The number of joining channels has to
%                  be larger than two. Multiple joining is also possible.
%                  (i.e., {[1,2],[3,4]})
%
%   Output:
%     newEpoch: Newly created epoch number will be added to original eegInfo.
%               Joined epoches will be generated with new name at the end
%               of the epoches. Taking newEpoch variable as an output is 
%               very important. If epoch information is not updated,
%               critical error might occure during data analysis.
%
% ---Usage---
%       [newEpoch] = joinConds('E01',{'S  1,'S  2','S  3'},30,...
%                               {'S  2','S  3'})
%
% ---Note----
% joinConds attaches two or more separate conditions. Newly joined conditions
% will be generated with new name at the end of the epoches. joinConds
% provides researchers with broader ways to study data, because newly added
% epoch information represents a new way to analyse erp data.
%
% see also: 

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function [newEpoch] = joinConds(fileName,epoches,numSubject,joinChans)
%% epoches, numSubject, fileName, 

% There are 3 dimensions in EEG.data
% 1: channals, 2: time lines, 3: condition epochs (1,2,3 choose. 
% which one do you want to concatenate?)
% conditions that needs to be joined.
%chans = {[2,3,4],[5,6,7]};
%dimset = [3]; % your choice: one dimension 

% find the path in which eeg data saved.
onePath = pathGuide;

% make error function whether checking there is 'BVreuslt' folder in this
% path.

% call all the epoches
numEpoch = length(epoches);

%% import data and join them.
numResult = numSubject;
initial = fileName(1);
epochInitial = epoches{1}(1);

% 1: channals, 2: time lines, 3: condition epochs (1,2,3 choose) 
% which one do you want to concatenate? set dimset
dimset = 3;

for trying = 1:numResult % number of subjects
    numTry = length(joinChans);
    resultPath = sprintf('%s%02d_BVresult',initial,trying);
    cd(fullfile(onePath,resultPath))
    con = 1;
    
    for trial = 1:numTry % number of join trails
        numJoin = length(joinChans{trial});
        chanName = joinChans{trial};
        
        for join = 1:numJoin % with channales, join them together.
            joint(join) = pop_loadset(sprintf('%s%02d_epoch_%02d.set',...
                initial,trying,chanName(join)));
        end
        jointedData = cat(dimset,joint(:).data);
        
        %%% Reconstruct the data %%%
        EEG.setname = joint(1).setname;
        EEG.filename = sprintf('%s%02d_epoch_%02d.set',initial,trying,numEpoch+con);
        EEG.filepath = '';
        EEG.subject = '';
        EEG.group = '';
        EEG.condition = '';
        EEG.session = [];
        EEG.comments = joint(1).comments;
        EEG.nbchan = joint(1).nbchan;
        EEG.trials = size(jointedData,3);
        EEG.pnts = joint(1).pnts;
        EEG.srate = joint(1).srate;
        EEG.xmin = joint(1).xmin;
        EEG.xmax = joint(1).xmax;
        EEG.times = joint(1).times;
        EEG.data = jointedData;
        EEG.icaact = [];
        EEG.icawinv = [];
        EEG.icasphere = [];
        EEG.icaweights = [];
        EEG.icachansind = [];
        EEG.chanlocs = joint(1).chanlocs;
        EEG.urchanlocs = [];
        EEG.ref = joint(1).ref;
        EEG.event = cat(2,joint(:).event);
        EEG.urevent = joint(1).urevent;
        EEG.eventdescription  = joint(1).eventdescription;
        EEG.epoch = cat(2,joint(:).epoch);
        EEG.epochdescription = joint(1).epochdescription;
        EEG.reject = joint(1).reject;
        EEG.stats = joint(1).stats;
        EEG.specdata = [];
        EEG.specicaact = [];
        EEG.splinefile = '';
        EEG.icasplinfile = '';
        EEG.dipfit = [];
        EEG.history = '';
        EEG.saved = joint(1).saved;
        EEG.etc = sprintf('%s%02d_epoch_%02d.fdt',initial,trying,numEpoch+con);
        %%% Reconstrcution End %%%
        
        % save the jointed conditions
        pop_saveset(EEG,sprintf('%s%02d_epoch_%02d',initial,trying,numEpoch+con));
        
        % add new epoch tags in eegInfo.
        epoches{numEpoch+con} = sprintf('%s %d',epochInitial,numEpoch+con);
        con = con+1;
    end
end

newEpoch = epoches;
cd(onePath)

