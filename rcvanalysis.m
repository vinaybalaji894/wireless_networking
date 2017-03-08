%% Demodulator using differentiator 
clear all;


fs = 240000;  % Front End sample rate 
ts = 1/fs; % sampling interval


load rcv.mat;


filename = 'rs.dat';
A = importdata(filename);

t = 0:ts:(length(rcv)-1)*ts; 

%% Draw the periodgram 

fftpoints= 2^ceil(log2(length(rcv)));
f_rcv = fft(rcv,fftpoints); 
PSD_rcv = fftshift(fft(rcv,fftpoints));
freq_rcv=(-fftpoints/2:fftpoints/2-1)/(fftpoints*ts)/1000;

% figure(1)
% plot(freq_rcv,abs(PSD_rcv))
% axis([-120 120 0 300]) % set x-axis and y-axis limits 
% xlabel('{\it f}(kHz)'); ylabel('{\it S}_{\rm FM}({\it f})')
% title('FM Amplitude Spectrum of modulated signal')

axisset = [-120 120 0 300];
freqset = freq_rcv;
periodgramdraw(PSD_rcv,axisset,freqset) 

%%  Demodulation and Rectifier 

diff_rc = diff(rcv); % Take Derivative of FM signal
diff_rcv = [0, diff_rc']'; 
abs_rcv = abs(diff_rcv);

figure(2)
subplot(211); fp1=plot(t,diff_rcv)
%axis(Trange) % set x-axis and y-axis limits 
xlabel('{\it t}(sec)'); ylabel('{\it d s}_{\rm FM}({\it t})')
title('FM Derivative')

subplot(212); fp2=plot(t,abs_rcv)
%axis(Trange) % set x-axis and y-axis limits 
xlabel('{\it t}(sec)'); %ylabel('{\it d}_{\rm PM}({\it t})')
title('rectified FM Derivative')

% PSD_absrcv = fftshift(fft(abs_rcv,fftpoints));
% axisset = [-120 120 0 300];
% freqset = freq_rcv;
% periodgramdraw(PSD_absrcv,axisset,freqset) 

%% Low pass filter 

N = 1;  
cutoff = 75000;  
[b,a]=butter(N,cutoff/(fs/2),'low');  
lpf_rcv = filter(b,a,abs_rcv);

% PSD_lpfrcv = fftshift(fft(lpf_rcv,fftpoints));
% axisset = [-120 120 0 300];
% freqset = freq_rcv;
% periodgramdraw(PSD_lpfrcv,axisset,freqset)  

%% Downsampling 

audio_rcv = downsample(lpf_rcv,fs/48000);
sound(audio_rcv,48000);


