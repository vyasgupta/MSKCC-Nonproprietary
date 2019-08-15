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
% adjacent min/max data points are averaged to create midpoints, which
% trace a pseudo-baseline of the waveform. Plots of these points along
% with the original waveform are displayed and the minima, maxima, and
% baseline points are stored into an Excel file for reference.

function waveformStats (filename)
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
if( min_t(1) < max_t(1) )
    [avg_t, avg_x] = baseline(min_t, minima, max_t, maxima);
else
    [avg_t, avg_x] = baseline(max_t, maxima, min_t, minima);
end

figure('name', 'Waveform with Baseline')
plot(t , x, avg_t, avg_x, '-b*')
grid on
xlabel('Time (s)') 
ylabel('Normalized Diaphragm Motion (mm)') 

%% saving values to Excel Files

minMat = [min_t(:) minima(:)];
maxMat = [max_t(:) maxima(:)];
avgMat = [avg_t(:) avg_x(:)];

delete('results.xlsx');

xlswrite('results.xlsx', minMat, 'Minima');
xlswrite('results.xlsx', maxMat, 'Maxima');
xlswrite('results.xlsx', avgMat, 'Average');


end

% Below subfunction assumes that the first value of t1 is smaller than the
% value of t2.
function [avg_t, avg_x] = baseline( t1 , x1 , t2 , x2 )

avg_t = zeros(0, 0);
avg_x = zeros(0, 0);

    for ind = 1:length(t2) - 1
        
        avg_t( 2 * ind - 1 ) = (t1(ind) + t2(ind)) / 2;
        avg_x( 2 * ind - 1 ) = (x1(ind) + x2(ind)) / 2;
        
        avg_t( 2 * ind ) = (t1(ind + 1) + t2(ind)) / 2;
        avg_x( 2 * ind ) = (x1(ind + 1) + x2(ind)) / 2;
        
    end
    
    % handles end depending on if there are more or equal amounts of both
    % types of extrema
    if(length(t1) == length(t2))
        
        avg_t(length(avg_t) + 1) = (t1(length(t1)) + t2(length(t2))) / 2;
        avg_x(length(avg_x) + 1) = (x1(length(x1)) + x2(length(x2))) / 2;
       
    else % case where there are more of extrema type 1
        
        avg_t(length(avg_t) + 1) = (t1(length(t1) - 1) + t2(length(t2))) / 2;
        avg_x(length(avg_x) + 1) = (x1(length(x1) - 1) + x2(length(x2))) / 2;
        
        avg_t(length(avg_t) + 1) = (t1(length(t1)) + t2(length(t2))) / 2;
        avg_x(length(avg_x) + 1) = (x1(length(x1)) + x2(length(x2))) / 2;
        
    end

end