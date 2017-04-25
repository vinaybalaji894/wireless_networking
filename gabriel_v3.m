%% GABRIEL_V1:Demodulating FM signal from scratch

%% Read complex samples from the rtlsdr file 
% SDR>rtl_sdr -s f_in_sps -f f_in_Hz -g gain_dB capture.bin
% Example: SDR>rtl_sdr -s 2400000 -f 70000000 -g 25 capture70R1k.bin
numfiles = 50;
mydata = cell(1, numfiles);

for k = 1:numfiles
myfilename = sprintf('location1_%d.bin', k);
fid = fopen(myfilename,'rb');
y = fread(fid,'uint8=>double');
y = y-127;
y = y(1:2:end) + i*y(2:2:end);


%% Low Pass filter Design

N=6;
cutoff=100000;
fs=240000;
%[b,a]=butter(N,cutoff/(fs/2),'low');
%lpf_1=filter(b,a,y);

h = FIR(fs,cutoff);
lpf = conv(h,y);
%% Decimating signal
x1=decimate(lpf,10);

%% Discriminator

X=real(x1);           % X is the real part of the received signal
Y=imag(x1);           % Y is the imaginary part of the received signal
N1=length(x1);         % N is the length of X and Y
b=[1 -1];            % filter coefficients for discrete derivative
a=[1 0];             %    "
derY=filter(b,a,Y);  % derivative of Y, 
derX=filter(b,a,X);  %    "          X,

disdata=(X.*derY-Y.*derX)./(X.^2+Y.^2);

%% The Second low pass filter


N=6;
cutoff=5000;
fs=240000;
%[b1,a1]=butter(N,cutoff/(fs/2),'low');
%lpf1=filter(b1,a1,disdata);
h1 = FIR(fs,cutoff);
lpf1 = conv(h1,disdata);
%% Decimate the second time to the sound card

x2=decimate(lpf1,5);

%% Hear the signal and change to .wav format

%sound(x2,48000)

%load handel.mat

%test1 = 'handel.wav';
%audiowrite(test1,x2,48000);
%%


mer1 = comm.MER('ReferenceSignalSource','Estimated from reference constellation','MeasurementIntervalSource','Custom','MeasurementInterval',48000,'MinimumMEROutputPort',true,'XPercentileMEROutputPort',true);

r=mer1(x2);
disp(r);
v=integratedLoudness(x2,48000);
disp(v);
T=[r;v];
fileID = fopen('exp.txt','a');
fprintf(fileID,'%.4f %.4f\r\n',T');
fclose(fileID);

end


