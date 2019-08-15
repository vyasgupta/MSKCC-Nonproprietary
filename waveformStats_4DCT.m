
% Author: Vyas Gupta
% Date: August 14, 2019
% Email: vyas100gupta@gmail.com or vgupta13@terpmail.umd.edu

% This function will take an excel file stored at the path 'filename'
% containing two columns of data: time and position. From there, it will
% determine significant extrema of the curve. "Significant" suggests that
% the extrema has a prominence above a certain threshold, which is manually
% inputted by the user. Promininece is a measure of how much an extrema
% protrudes from the curve, more of which can be read by googling "MATLAB
% prominence for extrema." After determining these significant extrema,
% average of all the position values between the first two minima is
% calculated and plotted as a horizontal line on top of the original
% waveform.

function waveformStats_4DCT (filename)
%% importing a waveform 
data = xlsread(filename);

t = data(:,1)';
x = data(:,2)';

% plot just to visualize
% figure, plot(t, x)

%% finding extrema and the baseline by averaging adjacent extrema

% finds the local extrema, ignoring extrema with a prominence < 2
% NOTE: MinProminence value can be configurable to your liking.
min = islocalmin(x, 'MinProminence', 1);
max = islocalmax(x, 'MinProminence', 1);

% isolating the minima points and the maxima points
min_t = t(min); minima = x(min);
max_t = t(max); maxima = x(max);

% plot to visualize these significant local extrema
figure('name', 'Waveform with significant extrema'), plot(t , x, min_t, minima, 'r*' , max_t, maxima, 'g*')
grid on
xlabel('Time (s)') 
ylabel('Normalized Diaphragm Motion (mm)') 

% based off of the requirements of the baseline function, we must use this
% if statment
avg_x = mean_disp(min, x);

figure('name', 'Waveform with Baseline')
plot(t , x)
yline(avg_x, '-', strjoin(["Average Displacement =" string(avg_x) "mm"]));
grid on
xlabel('Time (s)') 
ylabel('Normalized Diaphragm Motion (mm)')

end


function avg_x = mean_disp(min, x)

    min_idx = find(min);
    
    avg_x = mean(x(min_idx(1):min_idx(2) - 1));

end