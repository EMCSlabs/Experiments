% pathGuide: default path finder.
%
% ---Function Arguments---
%     onePath = pathGuide
%
%   Input:
%
%     (--): It is looking for eeglab file in order to set a default path.
%
%   Output:
%     onePath: Default path. The raw data should be saved this path.
%
% ---Usage---
%       onePath = pathGuide;
%
% ---Note----
% Data analysis runs on default path. Therefore, users should put their raw
% data (brain vision eeg data, behavioral test data) to this path. 
%
% see also: 

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function onePath = pathGuide

tmp_path = which('eeglab');
onePath = tmp_path(1:end-9);
cd(onePath)