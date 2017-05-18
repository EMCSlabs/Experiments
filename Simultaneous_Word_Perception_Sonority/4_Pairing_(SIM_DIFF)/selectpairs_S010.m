%% load full pairlist
clear;
load('paired');

%%
S010 = cell2table(pair.S010); 
S010.Var4 = categorical(S010.Var4);

S010_sim = S010(S010.Var4 == 'SIM',:);
S010_diff = S010(S010.Var4 == 'DIFF',:);

%% S010_sim
S010_s = []; 

for k = 1:height(S010_sim)
    
p = table2cell(S010_sim(randi(height(S010_sim),1),1:2));
p{1} = char(p{1});
p{2} = char(p{2});
S010_s = [S010_s;p];


S010_sim.Var1 = categorical(S010_sim.Var1);
S010_sim.Var2 = categorical(S010_sim.Var2);

S010_sim = S010_sim(S010_sim.Var1 ~= p{1},:);
S010_sim = S010_sim(S010_sim.Var1 ~= p{2},:);
S010_sim = S010_sim(S010_sim.Var2 ~= p{1},:);
S010_sim = S010_sim(S010_sim.Var2 ~= p{2},:);

end

S010_s(26:end,:) = [];

% ignore error and proceed to next section

%% S010_diff

S010_d = [];
for k = 1:height(S010_diff)
    
p = table2cell(S010_diff(randi(height(S010_diff),1),1:2));
p{1} = char(p{1});
p{2} = char(p{2});

S010_d = [S010_d;p];

S010_diff.Var1 = categorical(S010_diff.Var1);
S010_diff.Var2 = categorical(S010_diff.Var2);

S010_diff = S010_diff(S010_diff.Var1 ~= p{1},:);
S010_diff = S010_diff(S010_diff.Var1 ~= p{2},:);
S010_diff = S010_diff(S010_diff.Var2 ~= p{1},:);
S010_diff = S010_diff(S010_diff.Var2 ~= p{2},:);


end

%ignore error and proceed to save

%% save to .mat

save('S010_s.mat','S010_s');
save('S010_d.mat','S010_d');
