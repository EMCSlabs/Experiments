% erpPlot: plot the erp data.
%
% ---Function Arguments---
%     erpPlot(timeRange,erpAve,condInt)
%
%   Input:
%
%     timeRange: Time range between erp signal starts and ends. Time range
%                for plotting erp signals is adjustable. BUt mostly, this
%                time range follows epochRange set in eegInfo. (hlep eegInfo)
%     erpAve   : The condition averaged data that makred with time range.
%                erpAve can be attained from erpSubjAve or erpGrandAve  
%                functions.
%     
%     OPTIONAL
%     condInt  : (default:all) Conditions for plotting. Instead of plotting
%                all conditions, drawing specific conditions for comparison
%                is possible.
%               
%   Output:
%     (--): erp signals will be plotted. 
%
% ---Usage---
%       erpPlot([-200:800],erpAve,[1,2,3,4])
%
% ---Note----
% erpPlot visualizes the averaged erp signals. Comparison among all
% conditions or between speicific conditions are available by setting
% condInt variable. 
%
% see also: erpSubjAve, erpGrandAve

%                                  October.26.2015, Hyungwon Yang, Ver 1.0.
%                                                                 EMCS Lab


function erpPlot(timeRange,erpAve,condInt)
% erpTimeRange, 
%
%erpAve = main data
%timeTick = x axis time tick label.
timeTick = 50;


%% importing data

xTimeLine = timeRange(1,:);
xLine = size(erpAve,2);
erpLen = abs(timeRange(1))+abs(timeRange(end));
xWin = erpLen/timeTick;
xRange = 0:xLine/xWin:xLine;
xFlow = xTimeLine(1):timeTick:xTimeLine(end);
ymax = max(max(erpAve(2:end,:))) + 2;
ymin = min(min(erpAve(2:end,:))) - 2;
numCond = size(erpAve,1);
yTickZero = xRange(xFlow == 0);
erpLen = abs(timeRange(1))+abs(timeRange(end));
tickWin = 100;
for stack = 1:length(condInt)
     cons{stack} = ['condition: ' num2str(condInt(stack))];
end

% basic Setting
plot([0 xLine],[0 0],'k');hold on;   % xline
legend('pass');hold on;
plot([yTickZero yTickZero],[ymin ymax],'k');hold on; % yline
legend('pass');hold on;
axis([0 length(xTimeLine) ymin ymax]);hold on;
set(gca,'XTick',xRange,'XTickLabel',xFlow,'YDir','reverse');hold on;
axis([0 xLine ymin ymax]);hold on;
title('Event Related Potential Signals (Negative Upward)',...
    'fontsize',20)
xlabel('Latency (msec)','fontsize',15)
ylabel('Potential (uV)','fontsize',15)

% main plotting
plotdata = erpAve(2:end,:);
plotInt = length(condInt);
for p = 1:plotInt
    Int(p) = plot(plotdata(condInt(p),:));hold on;
    legend(Int(1:p),cons(1:p),'fontsize',15);
    grid on; 
    pause() 
end

