%% clearing

clearvars;
close all;

%% synthesizing a 1D waveform

time = 10; % range of time extends to 10 seconds
step = .01; % data points retrieved every .01 seconds

t = 0:step:time-step;       % setting the range of time from 0 to 10 seconds
smallFreq = 2.*(1 + rand(1));
x = sin(2*pi*t*20) + sin(2*pi*t*smallFreq); % *(1 + rand(1))
% low frequency waveform in the range of (2, 4)

% adding white gaussian noise/10% noise using randi function and plotting

% x = awgn(x, 10);
% x = (0.1 * x) .* randn([1 length(x)]) + x;

x = (0.1 * x) .* randi([-1 1], 1, length(x)) + x;


figure
plot(t, x)

%% finding the negative peaks of the waveform for higher frequency's baselines

[negpks, locs] = findpeaks(-x);
negpks = -negpks;
locs = locs * step - step;

figure
plot(t, x, locs, negpks)
legend('Waveform with Noise', '''Baseline'' of the Higher Frequency Wave');

figure
plot(locs, negpks)


%% use Fourier Transform to find the major frequency (period)

fourier = fft(x);
f = (0:length(x)-1)/(length(x)*step);
figure
plot(f, abs(fourier))

% t2 = locs(1):step:locs(end);
% baseline = interp1(locs, negpks, t2);
% 
% figure
% plot(t2, baseline);
% 
% baselineFourier = fft(baseline);
% fB = (0:length(baseline)-1)/(length(baseline)*step);
% figure
% plot(fB, abs(baselineFourier))

% four largest absolute values (two values for each of the two waveforms) and then picks the lower index

[B,I] = maxk(fourier,4,'ComparisonMethod','abs');

% min and max of I are indexes for the lower frequency's component in
% Fourier Transform --> will be used in last step to remove

% below code is just for clarity using the shift (shows which frequencies
% are there)

% n = length(y);                         
% 
% fshift = (-n/2:n/2-1)*(100/n);
% fourier_shift = fftshift(fourier);
% figure
% plot(fshift,abs(fourier_shift))

%% Removing the slow frequency from the bi-frequency waveform

fourier(max(I)) = 0;
fourier(min(I)) = 0; % removes low-frequency component

% low = sin(2*pi*t*f(min(I))); % removes low-frequency component
% lowFFT = fft(low);
% 
% figure
% plot(f, abs(lowFFT))
% 
% fourier = fourier - lowFFT;

figure
plot(f, abs(fourier))

out = ifft(fourier);

figure
plot(t, out)
grid on

%Input file path
% 'B:\George\Pawas_Shukla\Modified t-plan\PatientData\P14\Data_Fancy_Method\Motion Trace FB1-2-3_normalized.xlsx'
% 'B:\George\Pawas_Shukla\Modified t-plan\PatientData\P14\Data_Fancy_Method\Motion Trace 4DCT.xlsx'
