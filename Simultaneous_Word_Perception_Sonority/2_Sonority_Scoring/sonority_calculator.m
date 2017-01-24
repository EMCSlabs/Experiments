%% Sonority calculator (by word)
% Written by. Yejin Cho (2015.11.07)
clc;clear all; close all;
load cmufreq.mat; % The 522 extracted (frequently used 3 syllabled nouns) in cmudict
load arpabet2son.mat; % arpabet-sonority(1:1) score list

%% Calculate sonority for each word in cmufreq (table)
ox = []; count = []; score = []; sonority = [];

for k = 1:height(cmufreq);
    targ = cmufreq.Prono{k,1};
    
    for i = 1:height(arpabet2son);
        ox = strfind(targ, arpabet2son.ARPAbet{i,1});
        count{i,1} = length(ox);
        score(i) = count{i}*arpabet2son.Sonority(i);
        
    end
    sonority = [sonority ; sum(score)];
end

%% Save sonority score information to cmufreq(table)
cmufreq.Sonority = sonority;
cmufreq = sortrows(cmufreq,'Sonority','ascend');
% save('cmufreq_v2','cmufreq');

%% And the result is already saved for you
load 'cmufreq_v2.mat';