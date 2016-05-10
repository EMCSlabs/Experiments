%% Stress pattern extractor (by word)
% Written by. Yejin Cho (2015.11.25)
clc;clear all; close all;
load cmufreq_v2.mat;

%% (1) Extract Stress pattern by matching digits
matchStr = [];
for k = 1:height(cmufreq);
    str = cmufreq.Prono{k,1};
    expr = '\d';
    matchStr = [matchStr; regexp(str,expr,'match')];
end

%% (2) Combine the 3 stress info numbers into a single string
joined = [];

for i = 1:height(cmufreq);
    joined = [joined ; strjoin(matchStr(i,:))];
end

% convert string to cell
joined = cellstr(joined);

% Add stress info to the wordlist
cmufreq = [cmufreq joined];
cmufreq.Properties.VariableNames{4} = 'Stress';

%% (3) Save the result
% save('cmufreq_v3.mat', 'cmufreq');

% The result is already saved for you.
load 'cmufreq_v3.mat'