function [filtered_data, allchannels] = spike_detection(filtered_data, labels, allchannels, P, params)

% Provide feedback to the user.
disp([newline...
    '---------------- Intiating Stage 2 of the analysis ---------------- ' ...
    newline ...
    '(Rejection of channels based on detected spikes)'...
    newline newline ])
% Set a threshold (in mV)
jump_threshold = P.spikingthreshold;
% Initialize variable to hold the channels that will be rejected
% due to spiking activity
channels = size(filtered_data,1);
nr_jumps = zeros(channels,1);

textprogressbar([newline 'Detecting spiking channels.' newline])
timecount = linspace(1,100,size(filtered_data,1));
close all;
% Loop through the channels and detect abrupt changes
for chID = 1:size(filtered_data,1)
    textprogressbar(timecount(chID))
    nr_jumps(chID) = length(find(diff(filtered_data(chID,:)) > jump_threshold));
end
textprogressbar([newline 'Detection completed.'])

switch P.processing
    case 'slow'
        % Plot the spike-plot
        figureDim = [0 0 1 1];
        f = figure('units', 'normalized', 'outerposition', figureDim);
        bar(nr_jumps)
        title('Spiking Channels')
        xlabel('Channels')
        ylabel('Number of Spikes deteted')
        grid on
        grid minor
        pause(5)
        
        file_name = ['SpikingChannels_', settings.patient , '.png'];
        saveas(f, fullfile(settings.path2figures, file_name), 'png')
        close(f)
end

% Only keep voltage jumps that exceed the average fluctuation
average_fluctuation = floor(duration/params.srate);
exceeding_channels  = find(nr_jumps > average_fluctuation);

switch P.processing
    case 'slow'
        % Plot the spike-plot
        figureDim = [0 0 1 1];
        f = figure('units', 'normalized', 'outerposition', figureDim);
        for spikeCh = 1:length(exceeding_channels)
            plot(zscore(filtered_data(exceeding_channels(spikeCh),:)))
            title(['Label : ' labels(exceeding_channels(spikeCh))...
                'Channel Index : ' ...
                num2str(exceeding_channels(spikeCh))],'Interpreter','none')
            xlabel('time [samples]')
            ylabel('z-score')
            legend(['Channel ' num2str(spikeCh) '/' num2str(length(exceeding_channels)) newline '' ] ...
                ,'Location','northeastoutside')
            grid on
            grid minor
            pause(5)
        end
        close(f)
end

disp(['In total ' num2str(length(exceeding_channels)) ...
    ' have been removed due to spiking activity.'...
    newline ' The channels have the following labels : '  ])
disp(labels(exceeding_channels))

clear textprogressbar

% Update the logical channel variable and remove the trigger channel
allchannels(exceeding_channels) = false;
% Set the rejected channels to NaNs
filtered_data(exceeding_channels,:) = NaN;