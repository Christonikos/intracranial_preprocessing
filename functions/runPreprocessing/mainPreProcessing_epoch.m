function rejected_epochs = mainPreProcessing_epoch(epochs, args)
% This is the main function of the pre-processing pipeline at the epoch level. It is a modified pipeline based on
% the pipeline used at the Stanford University.
%
%    INPUTS :          
%                       1. epochs               : Cell   -  [number of blocks x 2]. 
%                                                           1st col: The loaded data file.
%                                                           2nd col: Information on the epoching method.
%                                       
%
%                       2. args                 : Struct -  The main configuration
%                                                           struct constructed
%                                                           @load_settings_args.params.m
%
%   OUTPUTS : 
%                       1. filtered_data        : Matrix - Data in format [channels x time]. Rejection of channels based on : 
%                                                       a.  Variance thresholding.
%
%                                                       b.  Pathological spike detection.
%
%                                                       c.  Deviation on the Power-spectrum.
%
%                                                       d. (Optional) HFOs detection.
%
%                                                       The rejected channels are replaced with NaNs. The non-rejected
%                                                       channels are linearly de-trended, downsampled to 1KHz and notch
%                                                       filtered for line noise and harmonics.
%
%                        
%                       2. rejectedchannels : Struct - Each field contains
%                                                      the indices of the rejected channels per TEST (see
%                                                      output 1).
%
%                       3. args             : Struct - In case of downsampling, we have 
%                                                      an updated sampling rate.
% -------------------------------------------------------------------------------------------------------------  
%% Input checks :
if isempty(epochs); error('empty input!');end

num_tests           = 4;
%% Get HFO bad trials:
%% ----------------------- TEST 1 - Reject based on spikes on the presence of HFOs --------------------------------------- %%
pTS = globalVar.pathological_event_bipolar_montage;
[bad_epochs_HFO, bad_indices_HFO] = exclude_trial(pTS.ts,pTS.channel, lockevent, globalVar.channame, epoch_params.bef_time, epoch_params.aft_time, globalVar.iEEG_rate);
%% ----------------------- TEST 2 - Reject based on spikes in LF and HF components of signal ----------------------------- %%
[be.bad_epochs_raw_LFspike, filtered_beh,spkevtind,spkts_raw_LFspike] = LBCN_filt_bad_trial(data_CAR.wave',data_CAR.fsample);
%% ----------------------- TEST 3 - Reject based on outliers of the raw signal and jumps --------------------------------- %%
[be.bad_epochs_raw_jump, badinds_jump] = epoch_reject_raw(data_CAR.wave,thr_raw,thr_diff);
%% ----------------------- TEST 4 - Reject based on spikes in HF component of signal ------------------------------------- %%
[be.bad_epochs_raw_HFspike, filtered_beh,spkevtind,spkts_raw_HFspike] = LBCN_filt_bad_trial_noisy(data_CAR.wave',data_CAR.fsample);


%% VIZUALIZE REJECTED EPOCHS %% 
if args.preferences.visualization
    plot_bad_channels(filtered_data, rejected_epochs);
end



