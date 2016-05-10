% eegGrandOne: Averaging one subjects' epoch data.
%
% ---Function Arguments---
%     eegGrandOne(fileName,epoches)
%
%   Input:
%
%     fileName: The folder in which a single subject's condition data stored.
%               Analysed data will be saved as 'fileName'_BVresult. This
%               name format was set for users convenience and easy
%               recognition of the folders. 
%     epoches : Epoch information which contains as cell. Based on the epoch
%               labels, this function will collect the all subjects' 
%               condition data.
%
%   Output:
%     (--): It will make a folder that contained averaged subject's data.
%
% ---Usage---
%       eegGrandOne('E01',{'S  1,'S  2','S  3'})
%
% ---Note----
% Different from eegGrandAll, this function averages each subject's
% condition data. The averaged data will be saved in the BVresult folder.
% Thus, the data will not be mingled with other averaged or raw data.
%
% see also: eegGrandAll, pop_grandaverage

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab

function eegGrandOne(fileName,epoches)

% grand averaging and saving: one subject, one epoch

% find the folder
onePath = pathGuide;
target_folder = [fileName '_BVresult'];
cd(fullfile(onePath,target_folder))

% import the data and averaging each epoch.
mkdir('epoch_averaged')
for num = 1:length(epoches)
    [averaged,~] = pop_grandaverage({sprintf('%s_epoch_%02d.set',fileName,num)});
    pop_saveset(averaged,sprintf('%s_averaged_%02d',fileName,num));
    movefile(sprintf('%s_averaged_%02d.*',fileName,num),...
        fullfile(onePath,target_folder,'epoch_averaged'))
end

cd(onePath)