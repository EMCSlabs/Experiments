%% Concatenate the two audiofile into the single file
load('S010_d.mat'); 
load('S010_s.mat');

% match S010_d& S010_s numbers
if length(S010_d) < length(S010_s)
    S010_s = S010_s(1:length(S010_d),:);
else
    S010_d = S010_d(1:length(S010_s),:);
end

% Save the resulting 25 pairs as 'pairs25'
pairs25 = [];
pairs25.S010_s = S010_s;
pairs25.S010_d = S010_d;

save('pairs25.mat', 'pairs25')

%% Download mp3 files
% getwordmp3(wordlist)

%% load mp3 file list
directory = cd;
% 여기다 fprintf해서 cd/mp3 되도록 수정하기 
cd('/Users/youngsuncho/Downloads/sonority/[05] Audio stimuli processing/mp3')
d = dir(fullfile('/Users/youngsuncho/Downloads/sonority/[05] Audio stimuli processing','*mp3'));
list = {d.name}';

% load stimuli list
% load pairlist.m
[len,~] = size(S010_s);
for k = 1:len
    aud1 = [lower(pairs{k,1}) '.mp3'];
    aud2 = [lower(pairs{k,2}) '.mp3'];
    [sig1, fs1] = audioread(aud1);
    [sig2, fs2] = audioread(aud2);
    [sig1, sig2] = matchAmp(sig1,sig2);
    [sig1, sig2] = matchLen(sig1,sig2);
    stim{k,1} = [sig1+sig2;zeros(5000,1);sig1+sig2];
    stim{k,2} = fs1;
    stim{k,3} = pairs{k,1};
    stim{k,4} = pairs{k,2};
end

% load pairlist.m
[len,~] = size(S010_d);
for k = 1:len
    aud1 = [lower(pairs{k,1}) '.mp3'];
    aud2 = [lower(pairs{k,2}) '.mp3'];
    [sig1, fs1] = audioread(aud1);
    [sig2, fs2] = audioread(aud2);
    [sig1, sig2] = matchAmp(sig1,sig2);
    [sig1, sig2] = matchLen(sig1,sig2);
    stim{k,1} = [sig1+sig2;zeros(5000,1);sig1+sig2];
    stim{k,2} = fs1;
    stim{k,3} = pairs{k,1};
    stim{k,4} = pairs{k,2};
end
    