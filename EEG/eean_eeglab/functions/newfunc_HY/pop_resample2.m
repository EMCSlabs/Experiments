% pop_resample2() - resample dataset (pop up window).
%
% Usage:
%   >> [OUTEEG] = pop_resample( INEEG ); % pop up interactive window
%   >> [OUTEEG] = pop_resample( INEEG, freq);
%
% Graphical interface:
%   The edit box entitled "New sampling rate" contains the frequency in
%   Hz for resampling the data. Entering a value in this box  is the same 
%   as providing it in the 'freq' input from the command line.
%
% Inputs:
%   INEEG      - input dataset
%   freq       - frequency to resample (Hz)  
%
% Outputs:
%   OUTEEG     - output dataset
%
% Author: Arnaud Delorme, CNL/Salk Institute, 2001
%
% Note: uses the resample() function from the signal processing toolbox
%       if present. Otherwise use griddata interpolation method (it should be
%       reprogrammed using spline interpolation for speed up).
%
% See also: resample(), eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% 01-25-02 reformated help & license -ad 
% 03-08-02 remove ica activity resampling (now set to []) -ad
% 03-08-02 debug call to function help -ad
% 04-05-02 recompute event latencies -ad

function [EEG, command] = pop_resample2( EEG, freq); 

command = '';
if nargin < 1
    help pop_resample;
    return;
end;     
if isempty(EEG(1).data)
    disp('Pop_resample error: cannot resample empty dataset'); return;
end;    

if nargin < 2 

	% popup window parameters
	% -----------------------
	promptstr    = {['New sampling rate']};
	inistr       = { num2str(EEG(1).srate) };
	result       = inputdlg2( promptstr, 'Resample current dataset -- pop_resample()', 1,  inistr, 'pop_resample');
	if length(result) == 0 return; end;
	freq         = eval( result{1} );

end;

% process multiple datasets
% -------------------------
if length(EEG) > 1
    [ EEG command ] = eeg_eval( 'pop_resample', EEG, 'warning', 'on', 'params', { freq } );
    return;
end;

% finding the best ratio
[p,q] = rat(freq/EEG.srate, 0.0001); % not used right now 

% set variable
% ------------
EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
oldpnts  = EEG.pnts;

% resample for multiple channels
% -------------------------
if isfield(EEG, 'event') & isfield(EEG.event, 'type') & isstr(EEG.event(1).type)
    tmpevent = EEG.event;
    bounds = strmatch('boundary', { tmpevent.type });
    if ~isempty(bounds),
        disp('Data break detected and taken into account for resampling');
        bounds = [ tmpevent(bounds).latency ];
        bounds(bounds <= 0 | bounds > size(EEG.data,2)) = []; % Remove out of range boundaries
        bounds(mod(bounds, 1) ~= 0) = round(bounds(mod(bounds, 1) ~= 0) + 0.5); % Round non-integer boundary latencies
    end;
    bounds = [1 bounds size(EEG.data, 2) + 1]; % Add initial and final boundary event
    bounds = unique(bounds); % Sort (!) and remove doublets
else 
    bounds = [1 size(EEG.data,2) + 1]; % [1:size(EEG.data,2):size(EEG.data,2)*size(EEG.data,3)+1];
end;

eeglab_options;
if option_donotusetoolboxes
    usesigproc = 0;
elseif exist('resample') == 2
     usesigproc = 1;
else usesigproc = 0;
    disp('Signal Processing Toolbox absent: using custom interpolation instead of resample() function.');
    disp('This method uses cubic spline interpolation after anti-aliasing (see >> help spline)');    
end;

fprintf('resampling data %3.4f Hz\n', EEG.srate*p/q);
eeglab_options;
for index1 = 1:size(EEG.data,1)
    fprintf('%d ', index1);	
    sigtmp = reshape(EEG.data(index1,:, :), oldpnts, EEG.trials);
    
    if index1 == 1
        tmpres = [];
        indices = [1];
        for ind = 1:length(bounds)-1
            tmpres  = [ tmpres; myresample( double( sigtmp(bounds(ind):bounds(ind+1)-1,:)), p, q, usesigproc ) ];
            indices = [ indices size(tmpres,1)+1 ];
        end;
        if size(tmpres,1) == 1, EEG.pnts  = size(tmpres,2);
        else                    EEG.pnts  = size(tmpres,1);
        end;
        if option_memmapdata == 1
             tmpeeglab = mmo([], [EEG.nbchan, EEG.pnts, EEG.trials]);
        else tmpeeglab = zeros(EEG.nbchan, EEG.pnts, EEG.trials);
        end;
    else
        for ind = 1:length(bounds)-1
            tmpres(indices(ind):indices(ind+1)-1,:) = myresample( double( sigtmp(bounds(ind):bounds(ind+1)-1,:) ), p, q, usesigproc );
        end;
    end; 
    tmpeeglab(index1,:, :) = tmpres;
end;
fprintf('\n');	
EEG.srate   = EEG.srate*p/q;
EEG.data = tmpeeglab;

% recompute all event latencies
% -----------------------------
if isfield(EEG.event, 'latency')
    fprintf('resampling event latencies...\n');

    for iEvt = 1:length(EEG.event)

        % From >> help resample: Y is P/Q times the length of X (or the
        % ceiling of this if P/Q is not an integer).
        % That is, recomputing event latency by pnts / oldpnts will give
        % inaccurate results in case of multiple segments and rounded segment
        % length. Error is accumulated and can lead to several samples offset.
        % Blocker for boundary events.
        % Old version EEG.event(index1).latency = EEG.event(index1).latency * EEG.pnts /oldpnts;

        % Recompute event latencies relative to segment onset
        if strcmpi(EEG.event(iEvt).type, 'boundary') && mod(EEG.event(iEvt).latency, 1) == 0.5 % Workaround to keep EEGLAB style boundary events at -0.5 latency relative to DC event; actually incorrect
            iBnd = sum(EEG.event(iEvt).latency + 0.5 >= bounds);
            EEG.event(iEvt).latency = indices(iBnd) - 0.5;
        else
            iBnd = sum(EEG.event(iEvt).latency >= bounds);
            EEG.event(iEvt).latency = (EEG.event(iEvt).latency - bounds(iBnd)) * p / q + indices(iBnd);
        end
        
    end

    if isfield(EEG, 'urevent') & isfield(EEG.urevent, 'latency')
        try
            for iUrevt = 1:length(EEG.urevent)
                % Recompute urevent latencies relative to segment onset
                if strcmpi(EEG.urevent(iUrevt).type, 'boundary') && mod(EEG.urevent(iUrevt).latency, 1) == 0.5 % Workaround to keep EEGLAB style boundary events at -0.5 latency relative to DC event; actually incorrect
                    iBnd = sum(EEG.urevent(iUrevt).latency + 0.5 >= bounds);
                    EEG.urevent(iUrevt).latency = indices(iBnd) - 0.5;
                else
                    iBnd = sum(EEG.urevent(iUrevt).latency >= bounds);
                    EEG.urevent(iUrevt).latency = (EEG.urevent(iUrevt).latency - bounds(iBnd)) * p / q + indices(iBnd);
                end

            end;
        catch
            disp('pop_resample warning: ''urevent'' problem, reinitializing urevents');
            EEG = rmfield(EEG, 'urevent');
        end;
    end;
    EEG = eeg_checkset(EEG, 'eventconsistency');
end;

% resample for multiple channels ica
EEG.icaact = [];

% store dataset
fprintf('resampling finished\n');

EEG.setname = [EEG.setname ' resampled'];
EEG.pnts    = size(EEG.data,2);
EEG.xmax    = EEG.xmin + (EEG.pnts-1)/EEG.srate; % cko: recompute xmax, since we may have removed a few of the trailing samples
EEG.times   = linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts);

command = sprintf('EEG = pop_resample( %s, %d);', inputname(1), freq);
return;

% resample if resample is not present
% -----------------------------------
function tmpeeglab = myresample(data, pnts, new_pnts, usesigproc);
    
    if length(data) < 2
        tmpeeglab = data;
        return;
    end;
    %if size(data,2) == 1, data = data'; end;
    if usesigproc
        % padding to avoid artifacts at the beginning and at the end
        % Andreas Widmann May 5, 2011
        
        %The pop_resample command introduces substantial artifacts at beginning and end
        %of data when raw data show DC offset (e.g. as in DC recorded continuous files)
        %when MATLAB Signal Processing Toolbox is present (and MATLAB resample.m command
        %is used).
        %Even if this artifact is short, it is a filtered DC offset and will be carried
        %into data, e.g. by later highpass filtering to a substantial amount (easily up
        %to several seconds).
        %The problem can be solved by padding the data at beginning and end by a DC
        %constant before resampling.

        [p, q] = rat(pnts / new_pnts, 1e-12); % Same precision as in resample
        N = 10; % Resample default
        nPad = ceil((max(p, q) * N) / q) * q; % # datapoints to pad, round to integer multiple of q for unpadding
        tmpeeglab = resample([data(ones(1, nPad), :); data; data(end * ones(1, nPad), :)], pnts, new_pnts);
        nPad = nPad * p / q; % # datapoints to unpad
        tmpeeglab = tmpeeglab(nPad + 1:end - nPad, :); % Remove padded data
        return;
    end;
    
    % anti-alias filter
    % -----------------
    data         = eegfiltfft(data', 256, 0, 128*pnts/new_pnts); % Downsample from 256 to 128 times the ratio of freq. 
                                                                 % Code was verified by Andreas Widdman March  2014
    
    % spline interpolation
    % --------------------
    X            = [1:length(data)];
    nbnewpoints  = length(data)*pnts/new_pnts;
    nbnewpoints2 = ceil(nbnewpoints);
    lastpointval = length(data)/nbnewpoints*nbnewpoints2;        
    XX = linspace( 1, lastpointval, nbnewpoints2);
    
    cs = spline( X, data);
    tmpeeglab = ppval(cs, XX)';
