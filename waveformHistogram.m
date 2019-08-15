
% Author: Vyas Gupta
% Date: August 14, 2019
% Email: vyas100gupta@gmail.com or vgupta13@terpmail.umd.edu

% This function will take an excel file stored at the path 'filename'
% containing two columns of data: time and position. From there, it will
% determine significant extrema of the curve. "Significant" suggests that
% the extrema has a prominence above a certain threshold, which is manually
% inputted by the user. Promininece is a measure of how much an extrema
% protrudes from the curve, more of which can be read by googling "MATLAB
% prominence for extrema." From here, the function creates a histogram. The
% binning is done by creating a certain number of horizontal lines within a
% range (the number and range are inputted by the user). The number of
% intersections between each line and the original waveform is then summed
% and divided by the number of cycles (inputted by the user for 4DMR or
% calculated for 4DCT by counting number of maximums). This is then graphed
% for the user.

% filename -> file path for the excel spreadsheet
% cycles -> number of cycles to average the values (input -1 for CT,
% function will then calculate and display number of cycles)
% num_bins -> the number of bins for the histogram
% max_amp -> upper threshold for binning ( multiplied by 2 at line 77 )

function waveformHistogram (filename, max_amp, cycles, num_bins)
%% importing a waveform 
data = xlsread(filename);

t = data(:,1)';
x = data(:,2)';

% plot just to visualize
% figure, plot(t, x)

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
    minpeak2 = minima(j+1);

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
    if length(binned) ~= 1
        bins(binned(end)) = bins(binned(end)) - 1; 
        bins(binned(1)) = bins(binned(1)) - 1;
    else
        bins(binned(1)) = bins(binned(1)) - 1;
    end
    
end

% determines number of cycles for 4DCT (user inputted cycles as -1) or uses
% the user input for 4DMR
if cycles == -1
    cycles = max(bins) / 2;
    disp(cycles);
    type = '4DCT';
else
    type = '4DMR';
end

% averages bins per cycle
bins = bins / cycles;

% display the bins
figure, bar(bin_thresholds, bins, 0.05);

%% saving values to Excel Files

binsMat = [bin_thresholds' bins'];
delete(['binningResults_' type '.xlsx']);
xlswrite(['binningResults_' type '.xlsx'], binsMat, 'Bins');

end

