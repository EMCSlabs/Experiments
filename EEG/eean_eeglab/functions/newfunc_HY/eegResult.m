% eegResult: Brain Vision EEG data analysis.
%
% ---Function Arguments---
%     eegResult(eegInfo)
%
%   Input:
%
%     eegInfo: main control information for analysis. The eegInfo
%              structure is required to be constructed before running 
%              this function. Type 'help eegAnalysis' for more information.
%       
%
%   Output:
%     (--): It will make folders that contains each subject's condition
%           results.
%
% ---Usage---
%       eegResult(eegInfo)
%
% ---Note----
% eegResult supports a number of methodologies to preprocess raw eeg data.
% Based on the eegInfo, eegResult runs several steps in order to make the
% raw data adequate to be used in real data analysis. Filtering,
% eye-movement correction, ICA and more techniques are available.
%
% see also: eegAnalysis

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function  eegResult(eegInfo)

if ~isstruct(eegInfo)
    error('Input must be a eegInfo structure variable.')
end

% Set the data directories.
onePath = pathGuide;

% EEG and BA data path
EEGin = fullfile(onePath,eegInfo.dataPath);
BAin = fullfile(onePath,eegInfo.baPath);

% save the data from the eeglab ver.10.

fileName = eegInfo.fileName;
curPath = EEGin;
dataName = [fileName '.vhdr'];

[EEG, com] = pop_loadbv(curPath, dataName);
ALLEEG = [];
ALLERP = [];
ALLERPCOM = [];
CURRENTERP = 0;
CURRENTSET = 0;

CURRENTSTUDY = 0;
ERP = [];
STUDY = [];
%% save the data file in eeglab ver.10
cd(curPath)
pop_saveset2(EEG,['test_' fileName],curPath,'off','savemode','resave');

%% import data, mat file from eeglab ver.10, to ver.13.
eeglab
close
EEG = pop_loadset(['test_' fileName '.set']);
delete(['test_' fileName '.set'],['test_' fileName '.fdt'])

%% channel location
cd(onePath)
elpPath = fullfile(onePath,'standard-10-5-cap385.elp');
EEG = pop_chanedit2(EEG,'lookup',elpPath);
%% reampling
EEG = pop_resample2(EEG,eegInfo.sampling);

%% basic FIR filter
EEG = pop_eegfilt(EEG,eegInfo.filter(1),eegInfo.filter(2),eegInfo.filter(3));


%% re-reference
EEG = pop_reref(EEG,eegInfo.reReference);

%% extract epoch
EEG = pop_epoch(EEG,eegInfo.epoch,eegInfo.epochRange);
EEG = pop_rmbase(EEG,eegInfo.baseRange);

%% Ocular Correction (gratton method)
% please import this value from eegInfo structure.
% EEG = pop_gratton(EEG);
if eegInfo.gratton.tell == 1
    
    [~,times,trials] = size(EEG.data);
    step = 1000/EEG.srate; % sampling step in ms
    EEG.data(eegInfo.chanInt,:,:) = gratton(EEG.data(eegInfo.chanInt,:,:),...
    reshape(EEG.data(eegInfo.gratton.eogChan,:,:), [times trials]),...
    eegInfo.gratton.blinkVolt, eegInfo.gratton.blinkWin/step);
end;


%% reject data based on BA result.
% load behavior test results.
cd(BAin)
BA = eegBA(eegInfo.BTName,eegInfo.trialNum);
cd(onePath)

% reject the abnormal time data. Only select the data in minmun and maximum
% time value.
pre_result = ~(eegInfo.BTminmax(1) <= BA.RT & BA.RT <= eegInfo.BTminmax(2));

% reject the data : correct(1) or incorrect(0)
post_result = BA.Accuracy == eegInfo.BTSelect;
%
test_result = pre_result + post_result;
for check = 1:length(test_result)
    if test_result(check) == 2;
        test_result(check) = test_result(check)-1;
    end
end
    

%% This function reject '1' marked data. leave the '0' marked data intact.
EEG = pop_rejepoch(EEG,test_result,0); 


%% 2. negative min to positive max abnormal values.
% Inputs:
%   INEEG      - input EEG dataset
%   typerej    - type of rejection (0 = independent components; 1 = raw
%              data). Default is 1. For independent components, before
%              thresholding the activations are normalized (to have std. dev. 1).
%   elec_comp  - [e1 e2 ...] electrode|component numbers to take 
%              into consideration for rejection
%   lowthresh  - lower threshold limit (in uV|std. dev. For components, the 
%              threshold(s) are in std. dev.). Can be an array if more than one 
%              electrode|component number is given in elec_comp (above). 
%              If fewer values than the number of electrodes|components, the 
%              last value is used for the remaining electrodes|components. 
%   upthresh   - upper threshold limit (in uV|std dev) (see lowthresh above)
%   starttime  - rejection window start time(s) in seconds (see lowthresh above)
%   endtime    - rejection window end time(s) in seconds (see lowthresh)
%   superpose  - [0|1] 0=do not superpose rejection markings on previous
%              rejection marks stored in the dataset: 1=show both current and
%              previously marked rejections using different colors. {Default: 0}.
%   reject     - [1|0] 0=do not actually reject the marked trials (but store the 
%              marks: 1=immediately reject marked trials. {Default: 1}.
%EEG = pop_eegthresh(EEG,1,[1:30],-80,80,-0.2,0.796,0,1);
EEG = pop_eegthresh(EEG,1,eegInfo.chanInt,eegInfo.reject(1),...
    eegInfo.reject(2),eegInfo.reject(3),eegInfo.reject(4),0,1);

%% ICA analysis
if eegInfo.ica.tell == 1
    EEG = pop_runica(EEG,'runica','extended',1);

% reject data after ICA analysis
    Reject = eegInfo.ica.reject; % find abnormal values
    [EEG,index] = pop_eegthresh(EEG,0,eegInfo.chanInt,Reject(1),...
        Reject(2),Reject(3),Reject(4),0,1);
    Trend = eegInfo.ica.trend; % find abnormal trends
    [EEG] = pop_rejtrend(EEG,0,eegInfo.chanInt,EEG.pnts,Trend(1),...
        Trend(2),0,1,0);
    Prob = eegInfo.ica.prob; % find improbable data
    [EEG,~,~,nrej] = pop_jointprob(EEG,0,eegInfo.chanInt,Prob(1),Prob(2)); % number of rejection.
    Kurt = eegInfo.ica.kurt; % find abnormal distribution
    [EEG,~,~,nrej,~] = pop_rejkurt(EEG,0,eegInfo.chanInt,Kurt(1),Kurt(2));
end

%% extract and save each conditon 
% save the data for further separate condition epoch extraction
mkdir([fileName '_BVresult'])
dataPath = fullfile(onePath,[fileName '_BVresult']);
cd(dataPath)
pop_saveset(EEG,[fileName '_allEpoch']);
epoch_saved = eegInfo.epoch;

for i = 1:length(epoch_saved)
    EEG = pop_loadset([fileName '_allEpoch.set']);
    EEG = pop_epoch(EEG,epoch_saved(i),eegInfo.epochRange);
    EEG = pop_rmbase(EEG,eegInfo.baseRange);
    pop_saveset(EEG,sprintf('%s_epoch_%02d',fileName,i));
end
cd(onePath)

