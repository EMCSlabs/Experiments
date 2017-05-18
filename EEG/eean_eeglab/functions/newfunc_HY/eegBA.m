% eegBA: EEG behavioral test analysis.
%
% ---Function Arguments---
%     BA = eegBA(fileName,epochNum,saveFile,booster)
%
%   Input:
%
%     fileName: The data contained text file name.
%     epochNum: The number of trial epoches. This will be used in order to 
%               detect the machine generated errors. The machine sometimes 
%               marks the epoch that should not be marked. In case,
%               epochNum information will check the numbers and raise the error.
%     OPTIONAL
%     saveFile: (default:0) Saving the BA result as a text file or not.
%               typle 1 if you want to save the file.
%     booster : (default:5) Speed up the process. Higher number is faster
%               than lower number. Do not set higher number if you have
%               lots of test words. The range is between 1 to 8.
%
%   Output:
%     BA: structural variable which contains Subject, Trial number,
%         Condition, Accuracy, Onset time, Offset time, and Response time. 
%
% ---Usage---
%       BA = eegBA('English_words.txt',10);
%
% ---Note----
% The text file that you are going to decompose should be saved from Brain
% Vision Analyser. And the number of trial test is very important because
% those information should be deleted. Therefore, the exact number of test
% trial is requisite. Otherwise, the result is unreliable.
%
% see also: 

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab

function [BA] = eegBA(fileName,epochNum,saveFile,booster)

% Error detection.
narginchk(2,4)

if nargin < 4
    booster = 5; % 5 is default value.
    saveFile = 0;end;
if (1 <= booster <= 8)
    bstr = booster;
else
    error('The booster should be set between 1 to 7'),end;

try
    fid = fopen(fileName,'r','n','UTF-16');
    sp = textscan(fid,'%s','delimiter','\n');
    if ~isempty(regexp(sp{1},'*** Header Start ***')),end;
    fclose(fid);
catch 
    error('This is not the text file from Brain Vision Analyser.')
end


% Importing data
warning off
fid = fopen(fileName,'r','n','UTF-16');
data = textscan(fid,'%s','delimiter','\n');
fclose(fid);
data = data{1};

% Extracting subject number and deleting trial sets.

shortNum = length(data)/bstr;

con = 1;
for i = 1:shortNum
    if ~isempty(regexp(data{i},'Subject'))
        subject = str2num(data{i}(10:end));        
    elseif ~isempty(regexp(data{i},'Level: 3'))
        lineNum(con) = i;
        con = con+1;
    end
end

newData = data(lineNum(1):end);

% Extracting 6 components.

con = 1;
for step = 1:length(newData)
    if ~isempty(regexp(newData{step},'Level: 3'))
        % The trial number will sequential. e.g., 1 to n(whole trials).
        Number(con) = str2num(newData{step+12}(15:end));
        % The word set condition.
        Condition(con) = str2num(newData{step+6}(12:end));
        % Right(1) or wrong(0) response from the subject.
        Accuracy(con) = str2num(newData{step+17}(16:end));
        % The time when the subjects sees the target words.
        OnsetTime(con) = str2num(newData{step+14}(22:end));
        % The time when the subject response to the target words.
        OffsetTime(con) = str2num(newData{step+16}(19:end));
        % Total response time : OffsetTime - OnsetTime
        RT(con) = str2num(newData{step+18}(15:end));
        con = con+1;
    end
end

% Summarize the components.
totalNum = size(Number,2);
AcAvr = floor((sum(Accuracy)/epochNum)*100);
RtAvr = floor(sum(RT)/totalNum);
fprintf('Subject %d - Accuracy : %d percent, Average RT : %d msec.\n',...
    subject,AcAvr,RtAvr);
if length(RT) ~= epochNum
    error('The number of epoches is not identical. Please check your epoch data')
end;

% Combines components into one structure.
B.Subject = subject;
B.Number = Number';
B.Condition = Condition';
B.Accuracy = Accuracy';
B.OnsetTime = OnsetTime';
B.OffsetTime = OffsetTime';
B.RT = RT';
B.Summary = [subject, AcAvr, RtAvr];    
    
BA = B;

% Writing it as a text file.

if saveFile == 1;
    
    fid = fopen(['BA_' fileName],'w','n','UTF-8');
    fprintf(fid,['Subject %d\n'...
    'Number\tCondition\tAccuracy\tOnsetTime\tOffsetTime\tRT\n'],BA.Subject);

    for i = 1:length(BA.Number)
        fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\n',BA.Number(i),BA.Condition(i),...
            BA.Accuracy(i),BA.OnsetTime(i),BA.OffsetTime(i),BA.RT(i));
    end
    fclose(fid);
end