function result = BAcheck(BAname,trialNum,condition,)
BAname = 'English_priming-01.txt';
trialNum = [400];  
condition = [1,2,3,4];


onePath = calleegInfo;

BA = eegBA(eegInfo.BTName,eegInfo.trialNum);

for cond = 1:length(condition)
    trial{cond} = BA.conditon == condition(cond);
end
