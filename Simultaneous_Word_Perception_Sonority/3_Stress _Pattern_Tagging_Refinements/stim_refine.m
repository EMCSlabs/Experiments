%% Stimuli refinements:
load 'cmufreq_v3.mat';

%% (1) Delete all quotations ('')
for i = 1:height(cmufreq)
    cmufreq.Word{i} = regexprep(cmufreq.Word{i},'''','');
    cmufreq.Prono{i} = regexprep(cmufreq.Prono{i},'''','');
    cmufreq.Stress{i} = regexprep(cmufreq.Stress{i},'''','');
end

%% (2) Delete all the inadequate words
%  A word was judged as 'inadequate'
%  if...
%    (i)  its recording sounds unnatural
%    (ii) it is too similar to other words in the list
%     (e.g. survival -¤µ survivor; one of them is removed)
%
%  FYI, This was done via Excel, not via MATLAB scripting.
%  In sum, 522 words were cut down into 333 words
%                       -> Saved as...
%                               'stimuli.mat'
%
%%
%  Please check the 'deleted_words.mat'
%          to see the list of deleted words.
%  (c.f. Part of the deleted words may not be included.)
