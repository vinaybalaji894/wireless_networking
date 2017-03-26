%% ARIEL_V1:Demodulating FM signal from scratch with RDS

%% Read complex samples from the rtlsdr file 
% SDR>rtl_sdr -s f_in_sps -f f_in_Hz -g gain_dB capture.bin
% Example: SDR>rtl_sdr -s 2400000 -f 70000000 -g 25 capture70R1k.bin

fid = fopen('106_3Mhz.bin','rb');
y = fread(fid,'uint8=>double');
y = y-127;
y = y(1:2:end) + i*y(2:2:end);


%% Low Pass filter Design

N=6;
cutoff=100000;
fs=240000;
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
h1 = FIR(fs,cutoff);
lpf1 = conv(h1,disdata);
%% Decimate the second time to the sound card

x2=decimate(lpf1,5);

%% Hear the signal

%sound(x2,48000)

%% Band Pass Filter for RDS


cutoff1=59000;
cutoff2=56000;
[b2,a2]=butter(N,cutoff2/(fs/2),'high');
bhpf=filter(b2,a2,disdata);
[b1,a1]=butter(N,cutoff1/(fs/2),'low');
blpf=filter(b1,a1,bhpf);



%% PLL loop with 19khz VCO 
fs3=240000;
[theta, phi_error] = pilot_PLL(disdata,19000,fs3,2,10,0.707);
b=[3];
angles=theta*b;
angles2=cos(angles);
%c=[];
%for m=1:100:1000000
    %c=[c (m/fs3)];
%end
%plot(c,phi_error(1:100:1000000))
%% Multiply BPF output to PLL output
result=blpf.*angles2;
z=length(result);
simpleSA(result,z,240000);

%% Low Pass filter 
cutoff3=22000;
fs3=350000;
[b3,a3]=butter(N,cutoff3/(fs3/2),'low');
fresult=filter(b3,a3,result);



%g=interp(fresult,20);

%z=length(g);
%simpleSA(g,z,17500,0,40);
