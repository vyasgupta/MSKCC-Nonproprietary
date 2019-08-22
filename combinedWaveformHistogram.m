
% Author: Vyas Gupta
% Date: August 14, 2019
% Email: vyas100gupta@gmail.com or vgupta13@terpmail.umd.edu

% This function will take two excel files stored at the paths
% 'filename_4DCT' and 'filename_4DMR', which both contain
% two columns of data: time and position. From there, it will
% determine significant extrema of the curves. "Significant" suggests that
% the extrema has a prominence above a certain threshold, which is manually
% inputted by the user. Promininece is a measure of how much an extrema
% protrudes from the curve, more of which can be read by googling "MATLAB
% prominence for extrema." From here, the function creates three histograms. 
% Binning is done by creating a certain number of horizontal lines within a
% range (the number and range are inputted by the user). The number of
% intersections between each line and the original waveforms is then summed
% and divided by the number of cycles (calculated by the number of maximums
% in the 4DCT). This will create individual histograms for the 4DCT and
% 4DMR, and finally a combined histogram.

function combinedWaveformHistogram (filename_4DCT, filename_4DMR, num_bins, max_amp)

% filename_4DCT -> file path for the 4DCT excel spreadsheet
% filename_4DMR -> file path for the 4DMR excel spreadsheet
% num_bins -> the number of bins for the histogram
% max_amp -> upper threshold for binning ( multiplied by 2 at line 77 )

% calls histogram function for 4DCT and 4DMR and returns the bins
[bin_thresh, bins, cycles] = wHistAux( filename_4DCT , max_amp , -1 , num_bins);
[ ~ , bins2 , ~ ] = wHistAux( filename_4DMR, max_amp , cycles , num_bins);

% combines the value into an array to plot on bar
comb_bin = [bins' bins2'];
figure, b = bar(bin_thresh, comb_bin, 0.5);

% labelling
title('Motion Trace Histogram');
xlabel('Tumor Displacement in Z-Axis')
ylabel('Average # of Incidences per Cycle')

% changes CT to green bars, MR to orange bars and sets the bar gap
b(1).FaceColor = 'g';
b(2).FaceColor = [0.8500 0.3250 0.0980];
b(1).BarWidth = 1;
b(2).BarWidth = 1;
    
%% saving values to Excel Files

binsMat = [bin_thresh' comb_bin];
delete('combinedBinningResults.xlsx');

xlswrite('combinedBinningResults.xlsx', binsMat, 'Bins');
    
end

function [bin_thresholds, bins, cycles] = wHistAux (filename, max_amp, cycles, num_bins)
%% importing a waveform 
data = xlsread(filename);

t = data(:,1)';
x = data(:,2)';

% plot just to visualize
figure, plot(t, x)

%% finding extrema and the baseline by averaging adjacent extrema

% finds the local extrema, ignoring extrema with a prominence < 2
% NOTE: MinProminence value can be configurable to your liking.
minVals = islocalmin(x, 'MinProminence', 1);
maxVals = islocalmax(x, 'MinProminence', 1);

% isolating the minima points and the maxima points
min_t = t(minVals); minima = x(minVals);
max_t = t(maxVals); maxima = x(maxVals);

%% Binning of the waveform at 5% increments of 2 * amplitude of 4DCT

% calculates the step percentage(for distance between horizontal binning 
% lines) and range limit for the horizontal bars
step = 1 / num_bins;
high = 2 * max_amp;

% creates list of values that represents the bins and an empty array of the
% same size to increment (bin)
bin_thresholds = - high : step * high :  high;
bins = zeros(size(bin_thresholds));

% for loop iterates through each maxima and bins based on adjacent minima
for j = 1:length(maxima)
    
    % fetching maxima and adjacent minima
    maxpeak = maxima(j);
    minpeak1 = minima(j);
    
    if j < length(minima)
        minpeak2 = minima(j+1);
    else
        minpeak2 = maxima(j);
    end
    
    % find which horizontal lines reside between the maxima and the left
    % minima and incrementing those values
    binned = find(bin_thresholds <= maxpeak & bin_thresholds >= minpeak1);
    bins(binned) = bins(binned) + 1;
    
    % finding which horizontal lines reside between the maxima and the
    % right minima and incrementing those values
    binned = find(bin_thresholds < maxpeak & bin_thresholds > minpeak2);
    bins(binned) = bins(binned) + 1;
    
    % accounting for double counting of the highest and lowest bin. if
    % statement checks that if highest and lowest bin are the same bin, it
    % is only subtracted once
    if length(binned) > 1
        bins(binned(end)) = bins(binned(end)) - 1; 
        bins(binned(1)) = bins(binned(1)) - 1;
    elseif length(binned) == 1
        bins(binned(1)) = bins(binned(1)) - 1;
    end
    
end

% determines number of cycles for 4DCT
if cycles == -1
    cycles = max(bins) / 2;
    type = '4DCT';
else
    type = '4DMR';
end

% averages bins per cycle
bins = bins / cycles;

% display the bins
figure, bar(bin_thresholds, bins, .05);
title(['Motion Trace Histogram - ' type]);
xlabel('Tumor Displacement in Z-Axis')
ylabel('Average # of Incidences per Cycle')

end

