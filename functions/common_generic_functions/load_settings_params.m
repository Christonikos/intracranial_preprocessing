function [settings, params, preferences, P] = load_settings_params(arguments)
% load_settings_params : Add the paths to the Data and the various
% toolboxes needed for the analysis.
%       INPUTS  :   varargin
%
%       OUTPUTS : 
%                   1. settings        : Struct - Holds the paths to
%                                                 various locations such as the data directory etc.
%                   2. params          : Struct - Holds various hospital-specific information such as the
%                                                 soa of the paradigm and the notch filtering parameters.
%                   3. preferences     : Struct - Returns the preferences
%                                                 struct including the following fields :
%                                                 3.1 : median threshold -
%                                                 This threshold will be
%                                                 later used on the
%                                                 rejection of channels
%                                                 based on non-pathological
%                                                 reasons.
%                                                 3.2 : spiking threshold -
%                                                 This threshold will be
%                                                 used to to detect spikes
%                                                 (abrupt voltage changes)
%                                                 in the signal.
%                                                 3.3 : visualization -
%                                                 "true"/"false" : The option "true"
%                                                 allows for visualization of the
%                                                 rejected electrodes at each stage
%                                                 of the pipeline.
%
%                   4.P                : Struct - Holds generic arguments
%                                                 such as the root path, 
%                                                 the datatype and the session.
% ---------------------------------------------------------------------------------------------
P = parsePairs(arguments);
%% -------- Default arguments -------- %%
checkField(P,'root_path', fullfile(filesep, 'neurospin','unicog', 'protocols', 'intracranial','example_project'));
checkField(P,'hospital' ,'Houston');
checkField(P,'patient'  ,'TS096');
checkField(P,'datatype' ,'Blackrock');
checkField(P,'session'  ,'s1')
%% General settings:
%------------------- Raw data path -------------------%
settings.path2rawdata   = fullfile(P.root_path,'data',   P.hospital , P.patient, P.session, filesep);
%------------------- Figures path -------------------%
settings.path2figures   = fullfile(P.root_path,'figures',P.hospital , P.patient, P.session, filesep);
%------------------- Output path -------------------%
settings.path2output    = fullfile(P.root_path,'output', P.hospital , P.patient, P.session, filesep);

%% General parameters:
params.jump_rate_thresh = 1;    % [Hz] For spike detection (stage 3): meximal number of jumps allowed per sec.
params.srate            = 2000;
% Set the notch-filtering bandwidth
params.first_harmonic{1}            = 59;
params.first_harmonic{2}            = params.first_harmonic{1}  + 2;
params.second_harmonic{1}           = 119;
params.second_harmonic{2}           = params.second_harmonic{1} + 2;
params.third_harmonic{1}            = 179;
params.third_harmonic{2}            = params.third_harmonic{1}  + 2;

%% Preferences
preferences.visualization           = false;
preferences.filter_sub_harmonics    = false;
preferences.medianthreshold         = 5;      % [var] used @stage 1
preferences.spikingthreshold        = 80;     % [mV]  used @stage 2
preferences.hfo_detection           = false;
preferences.downsampling            = 500;    % [Hz]


% -------------------- APPENDIX -------------------- %
% --- Houston Patients --- %
%   'TA719'
%   'TA724'
%   'TA750'
%   'TS083'
%   'TS096'
%   'TS097'
%   'TS100'
%   'TS101'
%   'TS104'
%   'TS107'
%   'TS109'
% ----------------------- %


P
