function [pE,pC] = spm_dcm_neural_priors(A,B,C,model)
% Prepares the priors on the parameters of neural mass models
% FORMAT [pE,pC] = spm_dcm_neural_priors(A,B,C,'model'))
%
% A,B{m},C  - binary constraints on extrinsic connections for m conditions
% 'model'   - 'ERP','SEP','CMC','LFP','NNM' or 'MFM'
%
% pE - prior expectation - f(x,u,P,M)
%
% synaptic parameters (for NMN and MFM)
%--------------------------------------------------------------------------
%    pE.T - synaptic time constants
%    pE.H - synaptic densities
%    pE.S - activation function parameters
%
% connectivity parameters
%--------------------------------------------------------------------------
%    pE.A  - extrinsic
%    pE.B  - trial-dependent
%    pE.C  - stimulus input
%
%    pE.SA - switches on extrinsic (excitatory)
%    pE.GE - switches on intrinsic (excitatory)
%    pE.GI - switches on intrinsic (inhibitory)
%
%    pE.D  - delays
%
% stimulus and noise parameters
%--------------------------------------------------------------------------
%    pE.R - onset and dispersion
%    pE.U - endogenous activity
%
% pC - prior (co)variances
%
% Because priors are specified under log normal assumptions, most
% parameters are simply scaling coefficients with a prior expectation
% and variance of one.  After log transform this renders pE = 0 and
% pC = 1;
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_dcm_neural_priors.m 5939 2014-04-06 17:13:50Z karl $
 
% check options
%==========================================================================
 
% get priors on neural model
%--------------------------------------------------------------------------
switch lower(model)
 
    % linear David et al model (linear in states)
    %======================================================================
    case{'erp','sep'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_erp_priors(A,B,C);
        
        
    % linear David et al model (Canonical microcircuit)
    %======================================================================        
    case{'cmc'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_cmc_priors(A,B,C);
        
    % linear David et al model (Canonical microcircuit with plasticity)
    %======================================================================        
    case{'tfm'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_tfm_priors(A,B,C);
        
 
    % linear David et al model (linear in states)  - with self-inhibition
    %======================================================================
    case{'lfp'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_lfp_priors(A,B,C);
 
 
    % Neural mass model (nonlinear in states)
    %======================================================================
    case{'nmm','mfm'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_nmm_priors(A,B,C);
        
            % Neural mass model (nonlinear in states)
    %======================================================================
    case{'nmda'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_nmda_priors(A,B,C);
        
    % Canonical neural mass model (nonlinear in states)
    %======================================================================
    case{'cmm'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_cmm_priors(A,B,C);
        
    % Canonical neural mass model with NMDA channels(nonlinear in states)
    %======================================================================
    case{'cmm_nmda'}
 
        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_cmm_NMDA_priors(A,B,C);
        
        
    % Neural field model (linear in states)
    %======================================================================
    case{'nfm'}

        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_nfm_priors(A,B,C); 
        
        
    % Null model - of Jacabian (linear in states)
    %======================================================================
    case{'null'}

        % prior moments on parameters
        %------------------------------------------------------------------
        [pE,pC] = spm_null_priors(A,B,C);
        
        
    otherwise
        warndlg('Unknown model')
end
