% eegplugin_grandaverage() - EEGLAB plugin for grand averaging epoched
%                            EEGLAB EEG datasets
%
% Usage:
%   >> eegplugin_grandaverage(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
%
% Author: Andreas Widmann, University of Leipzig, Germany, 2005

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2005 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de
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

% $Id$

function vers = eegplugin_grandaverage(fig, trystrs, catchstrs)

    vers = 'grandaverage1.1';
    if nargin < 3
        error('eegplugin_grandaverage requires 3 arguments');
    end

    % add folder to path
    % -----------------------
    if ~exist('pop_grandaverage')
        p = which('eegplugin_grandaverage');
        p = p(1:findstr(p,'eegplugin_grandaverage.m')-1);
        addpath([p vers]);
    end

    % find import data menu
    % ---------------------
    menu = findobj(fig, 'tag', 'tools');

    % menu callbacks
    % --------------
    comgavrsaved = [trystrs.no_check '[EEG LASTCOM] = pop_grandaverage;' catchstrs.new_and_hist];
    comgavrloaded = [trystrs.no_check '[EEG LASTCOM] = pop_grandaverage(ALLEEG);' catchstrs.new_and_hist];

    % create menus if necessary
    % -------------------------
    submenu = uimenu( menu, 'Label', 'Grand average datasets');
    uimenu(submenu, 'Label', 'Grand average datasets from files', 'CallBack', comgavrsaved);
    uimenu(submenu, 'Label', 'Grand average open datasets', 'CallBack', comgavrloaded);
