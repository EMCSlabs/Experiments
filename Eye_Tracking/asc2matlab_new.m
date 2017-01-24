function asc2matlab_new(FileName)

% this function takes an ascii file input and save the data as a mat file
% with the same filename as the ascii file

% input: FileName % .asc file
% output: a mat file

% modified by Hosung Nam
% sync information added

SaveFileName = [FileName(1:end-4) '.mat'];

WannaSave = 1; % To save the converted data as .mat file, this should be 1.
WannaPlot = 0; % To display the plot of the data, this should be 1.
ScreenRect = [1 1 1024 768]; % Data with gaze outside this rect will be discarded.

PacketSize = 20000; % 20000 rows will be processed at once.
% If you suffer with memory shortage, try to reduce PacketSize.
% Note that, however, small PacketSize will elongate the time required.


disp('--- [asc2matlab.m] -------------------------------------------');


%% Load the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Loading the data from ' FileName]);
fid = fopen(FileName,'rt');
Data = fread(fid,'char');
fclose(fid);
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done.']);
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Splitting the data into rows']);
Data = char(Data');
[Data, RowNum] = Text2CellArray(Data,PacketSize);
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done. (' num2str(RowNum) ' rows)']);


%% Classify the rows %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Classifying the rows']);
% Picking-up the rows with specific data-types
Types = [
    'MS'; % < 1> MSG
    'BU'; % < 2> BUTTON
    'SF'; % < 3> SFIX
    'EF'; % < 4> EFIX
    'SS'; % < 5> SSACC
    'ES'; % < 6> ESACC
    'SB'; % < 7> SBLINK
    'EB'; % < 8> EBLINK
    'PR'; % < 9> PRESCALER
    'VP'; % <10> VPRESCALER
    'EV'; % <11> EVENTS
    'SA'; % <12> SAMPLES
    'ST'; % <13> START
    'EN'; % <14> END
    ];
Category = zeros(1,RowNum);
temp = char(Data);
temp = temp(:,1:2); % Take first 2 characters of every row
for c=1:14 % for each category
    F = find((temp(:,1)==Types(c,1)) & (temp(:,2)==Types(c,2)));
    if c==13
        BlockNum = length(F);
        FS = F; % 'START' rows
    elseif c==14
        BlockNum = min([length(F) BlockNum]);
        FE = F; % 'END' rows
    end
    Category(F) = ones(1,length(F))*c;
end
clear temp;
% Classifying the rows
F = find(Category== 1);       MSG        = Data(F);
F = find(Category== 2);  Data_BUTTON     = Data(F);
F = find(Category== 3);  Data_SFIX       = Data(F);
F = find(Category== 4);  Data_EFIX       = Data(F);
F = find(Category== 5);  Data_SSACC      = Data(F);
F = find(Category== 6);  Data_ESACC      = Data(F);
F = find(Category== 7);  Data_SBLINK     = Data(F);
F = find(Category== 8);  Data_EBLINK     = Data(F);
F = find(Category== 9);       PRESCALER  = Data(F);
F = find(Category==10);       VPRESCALER = Data(F);
F = find(Category==11);       EVENTS     = Data(F);
F = find(Category==12);       SAMPLES    = Data(F);
F = find(Category==13);       START      = Data(F);
F = find(Category==14);       END        = Data(F);
% Picking-up data-only rows that is comprised of only values.
if BlockNum==0
    disp('No block is recorded in this file.');
    return;
else
    Data = char(Data);
    F = [];
    for b=1:BlockNum
        F = [F (FS(b)+1):(FE(b)-1)];
    end
    Data = Data(F,:);
end
clear FS FE;
DataRowChar = [double('0123456789.- ') 9]; % numbers, dot, minus, space and tab
DataRowNum = size(Data,1);
% To save memory, divide the data into several packets and process each
Fall = [];
for p=1:ceil(DataRowNum/PacketSize)
    S = (p-1)*PacketSize+1;
    E = p*PacketSize;
    if E>DataRowNum
        E = DataRowNum;
    end
    Packet = double(Data(S:E,:));
    temp = zeros(size(Packet,1),1);
    for c=1:length(DataRowChar)
        temp = temp + sum(Packet==DataRowChar(c),2);
    end
    F = find(temp==size(Packet,2));
    F = F + S - 1;
    Fall = [Fall; F];
end
clear temp F;
Data = [Data(Fall,:)];
clear Fall;
% report
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ... done. (' num2str(BlockNum) ' blocks found)']);


%% Convert the eye-position (X,Y) and pupil data into matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Interpreting the raw data']);
% To save memory, divide the data into several packets and process each
DataRowNum = size(Data,1);
RawData = [];
for p=1:ceil(DataRowNum/PacketSize)
    S = (p-1)*PacketSize+1;
    E = p*PacketSize;
    if E>DataRowNum
        E = DataRowNum;
    end
    Packet = [double(Data(S:E,:))]';
    L = numel(Packet);
    
    % Finding the null-data, represented by '.'
    % (e.g., gaze-positions are lost during blinks)
    NullData = find((Packet(1:L-2)==46)&(Packet(2:L-1)==46)&(Packet(3:L)==46)); % Finding "triple dots"
    NullData = [NullData find((Packet(1:L-1)==46)&(Packet(2:L)==9))]; % Finding "dot plus tab"
    NullData = [NullData find((Packet(1:L-1)==46)&(Packet(2:L)==32))]; % Finding "dot plus space"
    NullData = [NullData find((Packet(1:L)==46)&(mod([1:L],size(Packet,1))==0))]; % Finding dot at the end of the rows
    Packet(NullData) = ones(1,length(NullData))*48; % Replace the dot with zero.
    Data(S:E,:) = char(Packet');
    RawData = [RawData; str2num(Data(S:E,:))];
end
clear Packet NullData;
if size(RawData,1) < DataRowNum
    Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
    disp(['  ' Time '  !! The column numbers of the eye-posision data are not constant throughout.']);
    disp(['  ' char(ones(1,length(Time))*32) '  !! It may take longer time to process the data.']);
    for r=1:size(Data,1)
        NowData = str2num(deblank(Data(r,:)));
        L = length(NowData);
        RawData(r,1:L) = NowData;
    end
end
clear Data;
% Exclude the data if gaze position is outside the screen.
Fx = (RawData(:,2)>=ScreenRect(1)) & (RawData(:,2)<=ScreenRect(3));
Fy = (RawData(:,3)>=ScreenRect(2)) & (RawData(:,3)<=ScreenRect(4));
F  = (Fx & Fy);
clear Fx Fy;
RawData = RawData(find(F),:);
% report
temp = size(RawData,1);
temp = round(temp/RowNum*1000)/10;
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done. (' num2str(temp) '% data remain available)']);


%% Determining START/END of each block %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Detecting START/END timestamps of each block']);
% Find the timestamps of START and END
for b=1:BlockNum
    temp = double(char(START(b)));
    F = find(temp==9); % Find tab
    temp = temp((F(1)+1):F(2));
    STARTtime(b,:) = [b str2num(char(temp))];
    temp = double(char(END(b)));
    F = find(temp==9); % Find tab
    temp = temp((F(1)+1):F(2));
    ENDtime(b,:) = [b str2num(char(temp))];
end
% Add block numbers to the data
RawData = [zeros(size(RawData,1),1) RawData];
for b=1:BlockNum
    F = find( (RawData(:,2)>=STARTtime(b,2)) & (RawData(:,2)<=ENDtime(b,2)) );
    RawData(F,1) = ones(length(F),1)*b;
end
% report
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done.']);


% %% Convert the button-press data into matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
% disp(['  ' Time '  Interpreting the button-press data']);
% BUTTON = [];
% if isempty(Data_BUTTON)==0
%     BUTTON = double(char(Data_BUTTON));
%     BUTTON = BUTTON(:,8:size(BUTTON,2));
%     BUTTON = str2num(char(BUTTON));
% end
% % Appending block numbers to the data
% BUTTON = [zeros(size(BUTTON,1),1) BUTTON];
% for b=1:BlockNum
%     F = find( (BUTTON(:,2)>=STARTtime(b,2)) & (BUTTON(:,2)<=ENDtime(b,2)) );
%     BUTTON(F,1) = ones(length(F),1)*b;
% end
% clear Data_BUTTON;
% % report
% temp = size(BUTTON,1);
% Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
% disp(['  ' Time '  ...done. (' num2str(temp) ' changes of the button-state)']);


%% Convert the fixation data into matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Interpreting the fixation data']);
% SFIX: start of fixation
SFIX = [];
if isempty(Data_SFIX)==0
    SFIX = double(char(Data_SFIX));
    SFIX = SFIX(:,6:size(SFIX,2));
    F = find(SFIX(:,1)==76); % find 'L' (i.e., left eye)
    SFIX(F,1) = ones(length(F),1)*48; % Convert the 'L' into '0'
    F = find(SFIX(:,1)==82); % find 'R' (i.e., right eye)
    SFIX(F,1) = ones(length(F),1)*49; % Convert the 'R' into '1'
    SFIX = str2num(char(SFIX));
end
% EFIX: end of fixation
EFIX = [];
if isempty(Data_EFIX)==0
    EFIX = double(char(Data_EFIX));
    EFIX = EFIX(:,6:size(EFIX,2));
    F = find(EFIX(:,1)==76); % find 'L' (i.e., left eye)
    EFIX(F,1) = ones(length(F),1)*48; % Convert the 'L' into '0'
    F = find(EFIX(:,1)==82); % find 'R' (i.e., right eye)
    EFIX(F,1) = ones(length(F),1)*49; % Convert the 'R' into '1'
    EFIX = str2num(char(EFIX));
end
% Appending block numbers to the data
SFIX = [zeros(size(SFIX,1),1) SFIX];
EFIX = [zeros(size(EFIX,1),1) EFIX];
for b=1:BlockNum
    F = find( (SFIX(:,3)>=STARTtime(b,2)) & (SFIX(:,3)<=ENDtime(b,2)) );
    SFIX(F,1) = ones(length(F),1)*b;
    F = find( (EFIX(:,4)>=STARTtime(b,2)) & (EFIX(:,4)<=ENDtime(b,2)) );
    EFIX(F,1) = ones(length(F),1)*b;
end
clear Data_SFIX Data_EFIX;
% report
temp = max([size(SFIX,1) size(EFIX,1)]);
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done. (' num2str(temp) ' fixations)']);


%% Convert the saccade data into matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Interpreting the saccade data']);
% SSACC: Start of saccades
SSACC = [];
if isempty(Data_SSACC)==0
    SSACC = double(char(Data_SSACC));
    SSACC = SSACC(:,7:size(SSACC,2));
    F = find(SSACC(:,1)==76); % find 'L' (i.e., left eye)
    SSACC(F,1) = ones(length(F),1)*48; % Convert the 'L' into '0'
    F = find(SSACC(:,1)==82); % find 'R' (i.e., right eye)
    SSACC(F,1) = ones(length(F),1)*49; % Convert the 'R' into '1'
    SSACC = str2num(char(SSACC));
end
% ESACC: End of saccades
ESACC = [];
if isempty(Data_ESACC)==0
    ESACC = double(char(Data_ESACC));
    ESACC = ESACC(:,7:size(ESACC,2));
    F = find(ESACC(:,1)==76); % find 'L' (i.e., left eye)
    ESACC(F,1) = ones(length(F),1)*48; % Convert the 'L' into '0'
    F = find(ESACC(:,1)==82); % find 'R' (i.e., right eye)
    ESACC(F,1) = ones(length(F),1)*49; % Convert the 'R' into '1'
    
    % added by HN, the presence of even a single '.' in char(ESACC),
    % str2num would make all data empty. To prevent this, convert '.' to '0'
    ESACC = char(ESACC);
    for n = 1:size(ESACC,1)
        ESACC(n,:) = strrep(ESACC(n,:), ' .	', ' 0	');
    end
    ESACC = str2num(ESACC);
end
% Appending block numbers to the data
SSACC = [zeros(size(SSACC,1),1) SSACC];
ESACC = [zeros(size(ESACC,1),1) ESACC];
for b=1:BlockNum
    F = find( (SSACC(:,3)>=STARTtime(b,2)) & (SSACC(:,3)<=ENDtime(b,2)) );
    SSACC(F,1) = ones(length(F),1)*b;
    F = find( (ESACC(:,4)>=STARTtime(b,2)) & (ESACC(:,4)<=ENDtime(b,2)) );
    ESACC(F,1) = ones(length(F),1)*b;
end
clear Data_SSACC Data_ESACC;
% report
temp = max([size(SSACC,1) size(ESACC,1)]);
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done. (' num2str(temp) ' saccades)']);


%% Convert the blink data into matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Interpreting the blink data']);
% SBLINK: Start of blinks
SBLINK = [];
if isempty(Data_SBLINK)==0
    SBLINK = double(char(Data_SBLINK));
    SBLINK = SBLINK(:,8:size(SBLINK,2));
    F = find(SBLINK(:,1)==76); % find 'L' (i.e., left eye)
    SBLINK(F,1) = ones(length(F),1)*48; % Convert the 'L' into '0'
    F = find(SBLINK(:,1)==82); % find 'R' (i.e., right eye)
    SBLINK(F,1) = ones(length(F),1)*49; % Convert the 'R' into '1'
    SBLINK = str2num(char(SBLINK));
end
% EBLINK: End of blinks
EBLINK = [];
if isempty(Data_EBLINK)==0
    EBLINK = double(char(Data_EBLINK));
    EBLINK = EBLINK(:,8:size(EBLINK,2));
    F = find(EBLINK(:,1)==76); % find 'L' (i.e., left eye)
    EBLINK(F,1) = ones(length(F),1)*48; % Convert the 'L' into '0'
    F = find(EBLINK(:,1)==82); % find 'R' (i.e., right eye)
    EBLINK(F,1) = ones(length(F),1)*49; % Convert the 'R' into '1'
    EBLINK = str2num(char(EBLINK));
end
% Appending block numbers to the data
SBLINK = [zeros(size(SBLINK,1),1) SBLINK];
EBLINK = [zeros(size(EBLINK,1),1) EBLINK];
for b=1:BlockNum
    F = find( (SBLINK(:,3)>=STARTtime(b,2)) & (SBLINK(:,3)<=ENDtime(b,2)) );
    SBLINK(F,1) = ones(length(F),1)*b;
    F = find( (EBLINK(:,4)>=STARTtime(b,2)) & (EBLINK(:,4)<=ENDtime(b,2)) );
    EBLINK(F,1) = ones(length(F),1)*b;
end
clear Data_SBLINK Data_EBLINK;
% report
temp = max([size(SBLINK,1) size(EBLINK,1)]);
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done. (' num2str(temp) ' blinks)']);


%% Convert the MSG (message) data into matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  Interpreting the MSG data']);
MSGtemp = double(char(MSG));
temp = size(MSGtemp,1);
MSGtime = [];
if isempty(MSG)==0 % If there are MSG rows
    %    F = sum(MSGtemp==32);
    %    F = find(F==temp);
    %    if isempty(F) % If figures of the timestamps changes (e.g., 999999 -> 1000000)
    L = size(MSGtemp,2);
    MSGtemp2 = (MSGtemp==32); % find spaces
    for c=1:L
        mask(:,c) = sum(MSGtemp2(:,1:c),2);
    end
    mask = (mask==0);
    MSGtime = (MSGtemp.*mask) + (1-mask)*32; % Timestamps and spaces
    MSGtime = MSGtime(:,5:L); % Omit the "MSG + tab" of each row
    MSGtime = str2num(char(MSGtime));
    clear MSGtemp2 mask L;
    %   else
    %       F = F(1);
    %       MSGtime = str2num(char(MSGtemp(:,5:(F-1))));
    %   end
end
clear MSGtemp;
% Appending block numbers to the data
MSGtime = [zeros(temp,1) MSGtime];
for b=1:BlockNum
    F = find( (MSGtime(:,2)>=STARTtime(b,2)) & (MSGtime(:,2)<=ENDtime(b,2)) );
    MSGtime(F,1) = ones(length(F),1)*b;
end
% report
Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
disp(['  ' Time '  ...done. (' num2str(temp) ' MSG rows)']);

% added by HN to exclude blink and saccade data
RawData_NoBlinkSacc = RawData;
iBEG = []; iEND = [];
for m = 1: size(SBLINK, 1)
    iBEG = find(RawData_NoBlinkSacc(:,2)==SBLINK(m,3));
    iEND = find(RawData_NoBlinkSacc(:,2)==EBLINK(m,3));
    if ~isempty(iBEG) & ~isempty(iEND)
        RawData_NoBlinkSacc(iBEG:iEND,:) = [];
    end
end

iBEG = []; iEND = [];
for n = 1: size(SSACC, 1)
    iBEG = find(RawData_NoBlinkSacc(:,2)==SSACC(n,3));
    iEND = find(RawData_NoBlinkSacc(:,2)==ESACC(n,4));
    if ~isempty(iBEG) & ~isempty(iEND)
        RawData_NoBlinkSacc(iBEG:iEND,:) = [];
    end
end

%% Add sync info
% length of sync matches with trial number
% (currentEyeTrackerTime - (currentDisplayPCTime + AudioRecordingStartTime))
sync = [];
CET = []; CPT = []; ART = [];
if isempty(MSG) == 0
    for i = 1:size(MSG,2)
        if ~isempty(regexp(MSG{i},'currentEyeTrackerTime'))
            [~,idx] = regexp(MSG{i},'currentEyeTrackerTime ');
            idx = idx + 1;
            val1 = str2num(MSG{i}(idx:length(MSG{i})));
            CET = [CET;val1];
        elseif ~isempty(regexp(MSG{i},'currentDisplayPCTime'))
            [~,idx] = regexp(MSG{i},'currentDisplayPCTime ');
            idx = idx + 1;
            val2 = str2num(MSG{i}(idx:length(MSG{i})));
            CPT = [CPT;val2];
        elseif ~isempty(regexp(MSG{i},'AudioRecordingStartTime'))
            [~,idx] = regexp(MSG{i},'AudioRecordingStartTime ');
            idx = idx + 1;
            val3 = str2num(MSG{i}(idx:length(MSG{i})));
            ART = [ART;val3];
        end
    end
    sync = CET - CPT + ART;
    sync = sync';
end

%% Save the data as MATLAB's .mat file %%%%%%
if WannaSave==1
    Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
    disp(['  ' Time '  Save the data']);
    %     save(SaveFileName,'BUTTON','EBLINK','EFIX','END','ENDtime','ESACC','EVENTS','FileName','MSG','MSGtime','PacketSize','PRESCALER','RawData','SAMPLES','SBLINK','SFIX','SSACC','SaveFileName','ScreenRect','START','STARTtime','VPRESCALER');
    save(SaveFileName, 'EBLINK','EFIX','END','ENDtime','ESACC','EVENTS','FileName','MSG','MSGtime','sync','PacketSize','PRESCALER','RawData', 'RawData_NoBlinkSacc', 'SAMPLES','SBLINK','SFIX','SSACC','SaveFileName','ScreenRect','START','STARTtime','VPRESCALER');
    Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
    disp(['  ' Time '  ...done. (' SaveFileName ')']);
end


%% Plot the data %%%%%%
if WannaPlot==1
    Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
    disp(['  ' Time '  Plotting the data']);
    X = RawData(:,3); X = X';
    Y = RawData(:,4); Y = Y';
    % Pupil = RawData(:,4); Pupil = Pupil';
    plot(X,Y,'k-'), hold on;
    plot(EFIX(:,6),EFIX(:,7),'ro');
    axis ij;
    axis([ScreenRect(1) ScreenRect(3) ScreenRect(2) ScreenRect(4)]);
    Time=clock; Time=round(Time(4:6)); Time=[num2str(Time(1)) ':' num2str(Time(2)) ':' num2str(Time(3))];
    disp(['  ' Time '  ...done.']);
end


disp('-------------------------------------------------------------');

%% End of asc2matlab.m %%%%%%%%%%%%%%%%%%%%%%%%