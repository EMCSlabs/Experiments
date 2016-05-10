%% randomize stimuli
load stim.mat;
stim2 = stim(randperm(length(stim)),:);
save('stim_rand.mat', 'stim2')
