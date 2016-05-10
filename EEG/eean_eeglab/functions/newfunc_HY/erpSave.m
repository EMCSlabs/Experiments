% erpSave: Save analysed erp data.
%
% ---Function Arguments---
%     [erpData] = erpSave(erpTable,saveData,saveName)
%
%   Input:
%
%     erpTable: One or more erpTable data in cell. Theese tables will be
%               stacked and saved.
%
%     OPTIONAL
%     saveData: (default:0) Saving the erpTable data as a text file or not.
%               value 1 will save the erpTable data as csv file.
%     saveName: (default:'erpTable') The erpTable .csv file name. Put file
%               name then the file will be saved with that name.
%
%   Output:
%     erpData: Stacked erpData. It combines a number of erptable data.
%
% ---Usage---
%       [erpData] = erpSave(erpTable,1,'erpTable_analysis')
%
% ---Note----
% The erpTable will be sorted and reorganized in order for statistical
% analysis. This function stacks a number of erpTable data and saves them
% as csv file. The result data can be imported to excel or R for
% statistical analysis.
%
% see also: 

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab

function [erpData] = erpSave(erpTable,saveData,saveName)

% Set the default path and optional value
pathGuide;

if nargin < 2
    saveData = 0;
    saveName = 'erpTable';
end

% import data and prepare for dividing stacks based on channels.
stack = erpTable;
for i = 1:length(stack{1}) % how many channels?
    for j = 1:length(stack) % how many subjects?
        new_stack{i}{j} = stack{j}{i};
    end
end

comb = new_stack{1}{1};
for i = 1:length(new_stack{1})-1
    comb = [comb;new_stack{1}{i+1}(2:end,:)];
end

for i = 2:length(new_stack)
    for j = 1:length(new_stack{i})
        comb = [comb;new_stack{i}{j}(2:end,:)];
    end
end

% save data as .csv file.
if saveData == 1
    writetable(comb,sprintf('%s.csv',saveName));
end

% save output
erpData = comb;
    