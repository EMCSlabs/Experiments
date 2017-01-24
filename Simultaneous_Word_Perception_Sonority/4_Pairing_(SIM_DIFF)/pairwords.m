%% This script loads a .mat file wordlist 
% and pairs up the words in the imported .mat file 
clc;clear;close
%% import data (cmu3 syllables list)

load ('stimuli.mat');
stimuli = sortrows(stimuli,'Sonority','ascend'); % sort words by sonority scores
uq = unique(stimuli.Stress); % get a unique list of stress patterns

% re-numbering of the items
for i = 1:height(stimuli)
    stimuli.no(i) = i;
end

% pre-assign data space
data = {}; pair = struct();

%% Stress = 010
m=1;
for p = 1:length(stimuli.Stress);
    val = ~cellfun(@isempty,regexp(stimuli.Stress,uq{m}));
    list = stimuli.no(val);
end    

% pre-assign!
data =[];
for k = 1:length(list)-1 % W1-loop
    W1 = stimuli.Word(list(k)); % W1 is the 'k'th word
    
    for i = k+1:length(list) % W2-loop (comparison)
        W2 = stimuli.Word(list(i)); % W2 is the 'i'th word
        
        % Sonority comparison
        diff = stimuli.Sonority(list(i)) - stimuli.Sonority(list(k));
        data = [data;{W1 W2 diff}];
    end
end

% save to a field in the structure
name = sprintf('S%s',uq{m}); % stress pattern 'S0 1 0'
name = regexprep(name,' ',''); % delete spaces in the string (-> 'S010')
sname = sprintf('pair.%s',name); % field name pair.S010
eval([sprintf('%s = ',sname) 'data;']); % assign the data to sname (pari.S010)

%% Sonority pair classification: SIM / DIFF

for i = 1:length(pair.S010);
    diff = pair.S010{i,3};
    if diff <= 3
        % (1) Similar
        % if diff =< 3 pts
        pair.S010{i,4} = {'SIM'};
        
    elseif diff >= 35
        % (2) Different
        % if diff >= 30 pts
        pair.S010{i,4} = {'DIFF'};
        
    else
        pair.S010{i,4} = {'NULL'};
    end
end

%% The result file is already saved as .mat file
load 'stimuli.mat' 

