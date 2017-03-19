function h = FIR(fs,fc,M); 
% 64-tap Low Pass filter design
% FIR filter design with Hanning Window
% fs: sampling frequency
% fc: passband frequency 
clear all 

beta = 0; %% Lowpass filter must be ideal and symmetric. 
alpha = 0;  %% Using the case when the first sampling point is at zero frequency. 
M = 64;

for i = 0:1:M-1
    if((i<(fc/fs*M-alpha))||(i>((1-fc/fs)*M-alpha)))
        G(i+1) = (-1)^i;
    else 
        G(i+1) = 0;
    end 
end 

%%%%!!!!!!!!!!!!!!!!!!!!
U =  floor(fc/fs*M-alpha); 

%% FREQUENCY RESPONSE
k = 0:M-1;
n = 0:M-1;


ht = zeros(M,1);
for i = 1:1:M % n
     for j = 2:1:U+1 % k
         ht (i) = ht(i)+G(j)*cos(2*pi*(j-1)/M*(i-1+0.5));
     end
     ht(i) = (G(1)+2*ht(i))/M;
end
 
% plot(n,ht);
% figure(2)
% plot(abs(fft(ht,4096)));