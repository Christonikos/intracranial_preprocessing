% runPreprocessing: This is the pre-processing pipeline for the intracranial
% data. The goal of this scrip is to be as generic as possible, integrating
% data from various research centers such as the Houston medical center,
% the Marseille research center etc.
% Written by : Christos-Nikolaos Zacharopoulos @UNICOG 2018
%              christonik@gmail.com
% based on a similar pipeline used at the Stanford University.
% This is a plug-and-play function, to change any input variable, provide it
% as a pair-input  in the command window.
% example : 
% runPreprocessing('patients',{'TS096'},'medianthreshold',4,'spikingthreshold',80);
% --------------------------------------------------------------------------------------------------
function runPreprocessing(varargin)
%% -----------  BRANCH 1 - SET THE PATHS ----------- %
% In this branch we define the paths for the user.
clc;  close all;
% Add the dependencies on the path
addpath(genpath(fullfile(pwd,'functions','supportive_general_functions')));
addpath(genpath(fullfile(pwd,'functions','common_generic_functions')));
addpath(genpath(fullfile(pwd,'functions','runPreprocessing')));
% Keep the workspace clean
clearvars -except varargin
%Check whether the debug mode is on
if feature('IsDebugMode')
    dbquit all
end
% Get the data path based on the hostname of the computer in use. The
% variables are unaffected from the OS.
[~,hard_drive_path, elecs_path] = getCore;
%% -----------  BRANCH 2 - SPECIFY THE RESEARCH CENTER  AND THE CLEANING PARAMETERS ----------- %
% In this branch we manunally add the list of patients that corresponds to each
% individual project.
P = parsePairs(varargin);
checkField(P,'processing','quick'); %'slow'/'quick'.
% The option "slow" allows for visualization of the rejected electrodes at
% each stage of the pipeline.
checkField(P,'Hospital',{'Houston'});
% get the hospital-ID
hopID = P.Hospital{1};
%% -----------  BRANCH 3 - SPECIFY HOSPITAL SPECIFIC PARAMETERS ----------- %
% Here, we update the configuration structure P with the list of patients
% and the recording methods that correspond to that hospital.
switch hopID
    % Get the list of patients and update the P structure
    case 'Houston'
        % -------- Patients -------- %
        checkField(P,'patients',{'TS096'});
        % -------- Recording methods -------- %
        checkField(P,'recordingmethod',{'sEEG'}); % to do: integrate the grid method
        checkField(P,'datatype',{'Blackrock'});
        % -------- Cleaning Thresholds -------- %
        checkField(P,'medianthreshold', 5);     % distance from the median
        checkField(P,'spikingthreshold',80);    % spiking threshold
        checkField(P,'rereference','bipolar');  % commonaverage, clinical
end
% get the patient-ID
patid       = P.patients{1};
% get the method-ID (sEEG, grid).
recID       = P.recordingmethod{1};
datatypeID  = P.datatype{1};
%% -----------  BRANCH 4 - LOAD THE RAW DATA ----------- %
% load settings and parameters
[settings, params] = load_settings_params(hard_drive_path,patid, recID, hopID);
% load the raw data : matrix of dimensions : [channels x time].
% It contains the broadband activity from 
[raw_data, ~ ,labels, gyri, ~,  params, recordings] = ...
    load_raw_data(settings, P, params, datatypeID, elecs_path, recID, hopID);
%% -----------  BRANCH 5 - MAIN  CHANNEL REJECTION ANALYSIS----------- %
% Memory pre-allocation
clean_data       = cell(size(raw_data,1),size(raw_data,2)); 
% clean_data       : Cell - Each entry corresponds to a recording session 
%                           and is a matrix of dimensions : [channels x time]. 
%                           It will contain the cleaned channels. 
%                           The rejected channels will be  filled with NaNs.
indexofcleandata = cell(size(raw_data,1),1);
% indexofcleandata : Cell - Each entry corresponds to a recording session and
%                           is a logical matrix of dimensions : [channels x 1].
%                           It will contain the index of the rejected channels 
%                           (0 == rejected).
m = @mainPreProcessing;
% loop through recordings
for recording = 1:numel(recordings)
% function handle to the main function.
[clean_data{recording}, indexofcleandata{recording }] = ...
    m(P, settings, raw_data{recording }, params, labels, gyri, hopID, recording, recordings);
end
clear raw_data
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















