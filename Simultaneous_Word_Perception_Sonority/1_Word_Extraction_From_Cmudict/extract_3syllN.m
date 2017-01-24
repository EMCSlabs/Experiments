%% CMU dictionary: 3 syll lemma extraction
% Written by. Yejin Cho (2015.11.07)
clc; clear; close all
load 'cmudict.mat';

%% (1) Count the number of syllables of each word
%      by counting the number of integers
%      in the second column (prono)
%     (# of stress(int) = # of vowel = # of syll)

num_syll = [];
for i = 1: height(C)
    ans = regexp(C{i,2},'[0-9]'); % get location of integers in each word
    tmp = length(ans{1,1}); % count the number of (location of) integers
    num_syll = [num_syll ; tmp]; % concatenate horizontally
end

% Add num_syll information as a new column in "C"(cmudict).
C.Syll = num_syll;

%% (2) Extract 3 syllable words from cmudict
Word3 = []; Prono3 = []; Syll3 = [];

for i=1:height(C);
    if C{i,3} == 3;
        Word3 = [Word3 ; C{i,1}];
        Prono3 = [Prono3 ; C{i,2}];
        Syll3 = [Syll3 ; C{i,3}];
    end
end

% Save as C3 (table)
C3 = table(Word3, Prono3, Syll3,...
    'VariableNames', {'Word' 'Prono' 'Syll'});

%% (3) Extract high frequency words
%      by comparing the words in 'C3' (3syll words in cmudict)
%                to the words in 'freqwords'(from COCA database)

load 'freqwords.mat';
val = [];
TF = [];
for i = 1:height(C3);
    TF = strcmpi(C3{i,1}, freqwords{1:end,1});
    TF = double(TF);
    
    if any(TF(:)==1)==1;
        val(i) = 1;
    else val(i) = 0;
    end
end

val = val';

% Save the frequency info as another column to C3(table)
C3.Freq = val;

%% (4) Create a new table with high frequency words only

cmufreq = [];
Wordf = [];
Pronof = [];
Syllf = [];

for i=1:height(C3);
    if C3.Freq(i)==1;
        Wordf = [Wordf ; C3{i,1}];
        Pronof = [Pronof ; C3{i,2}];
        Syllf = [Syllf ; C3{i,3}];
    end
end

cmufreq = table(Wordf, Pronof,...
    'VariableNames', {'Word' 'Prono'});

%% The resulting full list is already saved as .mat
% The collected 522 words satisfies 3 conditions:
%   1) frequently used
%   2) 3 syllable long
%   3) nouns

% The result table is named as 'cmufreq'
load 'cmufreq.mat';
