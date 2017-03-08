userInput = helperFMUserInput;
[fmRxParams,sigSrc] = helperFMConfig(userInput);
radioTime = 0;
while radioTime < userInput.Duration
  % Receive baseband samples (Signal Source)
  if fmRxParams.isSourceRadio
    [rcv,~,lost,late] = sigSrc();
  else
    rcv = sigSrc();
    lost = 0;
    late = 1;
  end

  % Update radio time. If there were lost samples, add those too.
  radioTime = radioTime + fmRxParams.FrontEndFrameTime + ...
    double(lost)/fmRxParams.FrontEndSampleRate;
end
a=length(rcv);
rv=[];
iv=[];
for i= 1:a
    am=abs(rcv(i));
    ag=angle(rcv(i));
    rv(i)=am*cos(ag);
    iv(i)=am*sin(ag);
end
figure(1)
plot(rv)
figure(2)
plot(iv)
figure(3)
plot(real(rcv))
figure(4)
plot(imag(rcv))


% Release the audio and the signal source
release(sigSrc)
