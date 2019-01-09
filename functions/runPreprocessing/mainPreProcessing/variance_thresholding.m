function rejected_channels = variance_thresholding(filtered_data, rejected_channels, args)

test_number = 1;
% Get the variance of all channels
disp([newline '-----------------------------------------' ...
newline 'test #1 : Channel rejection based on signal variance.'])
% Pre-allocate the variance variable
dataVariance    = zeros(1,size(filtered_data,1));
for channel = 1: size(filtered_data,1)
    dataVariance(1,channel) = var(filtered_data(channel,:)');
end


switch args.preferences.visualization
    case true
        figureDim = [0 0 1 1];
        figure('units', 'normalized', 'outerposition', figureDim)
        subplot(211)
        bar(dataVariance)
        grid on
        grid minor
        xlabel('channels')
        ylabel('detected variance')
        title('Detected variance for all channels')
        hold on
        plot([get(gca,'xlim')],[5*median(dataVariance),5*median(dataVariance)],'r','linew',1.2)
        hold on
        plot([get(gca,'xlim')],[median(dataVariance)/5,median(dataVariance)/5],'m','linew',1.2)
        legend('detected variance','5*median','median/5','Location',  'northeastoutside')
        
        subplot(212)
        bar(dataVariance)
        grid on
        grid minor
        xlabel('channels')
        ylabel('detected variance')
        title('Detected variance for all channels')
        xlim([0 20])
        hold on
        plot([get(gca,'xlim')],[5*median(dataVariance),5*median(dataVariance)],'r','linew',1.2)
        hold on
        plot([get(gca,'xlim')],[median(dataVariance)/5,median(dataVariance)/5],'m','linew',1.2)
        legend('detected variance','5*median','median/5','Location',  'northeastoutside')
        pause(10)
        close all
end
% Set the cutting threshold
medianthreshold             = args.params.medianthreshold;
% Detect those channels that exceed 5 times the median of the
% detected variance (in both directions) 
deviant_positive    = find(dataVariance > (medianthreshold * median(dataVariance)));
deviant_negative    = find(dataVariance < (median(dataVariance)/medianthreshold));
% Concatenate the detected channels
deviant_channels            = sort([deviant_negative deviant_positive]);
disp([num2str(length(deviant_channels)) ' channels have been removed.']);

% Update the logical channel variable #test 1
rejected_channels(deviant_channels',test_number) = false;

if args.preferences.visualization
    % Plot the bad channels
    figureDim = [0 0 1 1];
    figure('units', 'normalized', 'outerposition', figureDim)
    for bch = 1:length(deviant_channels)
        if bch == 1
            t = text(0.5,0.5,'These are the channels rejected from step 1');
            t.BackgroundColor = 'k';
            t.Color = 'w';
            t.FontSize = 25;
            t.FontWeight = 'Bold';
            t.FontSmoothing = 'on';
            t.Clipping = 'on';
            t.HorizontalAlignment = 'center';
            axis off;
            pause(3)
        end
        plot(zscore(filtered_data(deviant_channels(bch),:)))
        title(['Channel Index : ' ...
                num2str(deviant_channels(bch))],'Interpreter','none') %#ok<NODEF>
        xlabel('Time [samples]')
        ylabel('zscore')
        grid on
        grid minor
        legend(['Channel ' num2str(bch) '/' num2str(length(deviant_channels)) newline '' ] ...
            ,'Location','northeastoutside')
        pause(5)
    end
    close all
end
