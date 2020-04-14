%%%      2阶锁相环仿真文件    %%%
%%%%          PLL_2ord_sim2.m         %%%%   

%   date: 2020-02-29    author: zjw    %%


%%%%   程序说明
%本程序实验MATLAB帮助文件中给出的8PSK的使用放法
%

%%%        仿真环境 
% 软件版本：matlab 2019a
% 信号源：采用频率阶跃信号

%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%
% %c6_nltvde.m
% w2b=0; w2c=0; % initialize integrators
% yd=0; y=0; % initialize differential equation
% tfinal = 50; % simulation time
% fs = 100; % sampling frequency
% delt = 1/fs; % sampling period
% npts = 1+fs*tfinal; % number of samples simulated 仿真用到的采样点数
% ydv = zeros(1,npts); % vector of dy/dt samples
% yv = zeros(1,npts); % vector of y(t) samples
% %
% % beginning of simulation loop
% for i=1:npts
%     t = (i-1)*delt; % time
%     if t<20%??这是什么？输入信号？
%         ydd = 4*exp(-t/2)-3*yd*abs(y)-9*y; % de for t<20
%     else
%         ydd = 4*exp(-t/2)-3*yd-9*y; % de for t>=20
%     end
%     w1b=ydd+w2b; % first integrator - step 1
%     w2b=ydd+w1b; % first integrator - step 2
%     yd=w1b/(2*fs); % first integrator output
%     w1c=yd+w2c; % second integrator - step 1
%     w2c=yd+w1c; % second integrator - step 2
%     y=w1c/(2*fs); % second integrator output
%     ydv(1,i) = yd; % build dy/dt vector
%     yv(1,i) = y; % build y(t) vector
% end % end of simulation loop
% plot(yv,ydv) % plot phase plane
% xlabel('y(t)') % label x axis
% ylabel('dy/dt') % label y zxis
% % End of script file.
% 
% % File: pllpost.m
% %
% kk = 0;
% while kk == 0
%     k = menu('Phase Lock Loop Postprocessor',...
%     'Input Frequency and VCO Frequency',...
%     'Input Phase and VCO Phase',...
%     'Frequency Error','Phase Error','Phase Plane Plot',...
%     'Phase Plane and Time Domain Plots','Exit Program');
%     if k == 1
%         plot(t,fin,'k',t,fvco,'k')
%         title('Input Frequency and VCO Freqeuncy')
%         xlabel('Time - Seconds');ylabel('Frequency - Hertz');pause
%     elseif k ==2
%         pvco=phin-phierror;plot(t,phin,t,pvco)
%         title('Input Phase and VCO Phase')
%         xlabel('Time - Seconds');ylabel('Phase - Radians');pause
%     elseif k == 3
%         plot(t,freqerror);title('Frequency Error')
%         xlabel('Time - Seconds');ylabel('Frequency Error - Hertz');pause
%     elseif k == 4
%         plot(t,phierror);title('Phase Error')
%         xlabel('Time - Seconds');ylabel('Phase Error - Radians');pause
%     elseif k == 5
%         ppplot
%     elseif k == 6
%         subplot(211);phierrn = phierror/pi;
%         plot(phierrn,freqerror,'k');grid;
%         title('Phase Plane Plot');xlabel('Phase Error /Pi');
%         ylabel('Frequency Error - Hertz');subplot(212)
%         plot(t,fin,'k',t,fvco,'k');grid
%         title('Input Frequency and VCO Freqeuncy')
%         xlabel('Time - Seconds');ylabel('Frequency - Hertz');subplot(111)
%     elseif k == 7
%         kk = 1;
%     end
% end % End of script file.


% File: pllpre.m
%
%clear;% be safe
disp(' ') % insert blank line
fdel = input('Enter the size of the frequency step in Hertz > ');
fn = input('Enter the loop natural frequency in Hertz > ');
lambda = input('Enter lambda, the relative pole offset > ');
disp(' ')
disp('Accept default values:')
disp(' zeta = 1/sqrt(2) = 0.707,')
disp(' fs = 200*fn, and')
disp(' tstop = 1')
dtype = input('Enter y for yes or n for no > ','s');
if dtype == 'y'
    zeta = 1/sqrt(2);
    fs = 200*fn;
    tstop = 1;
else
    zeta = input('Enter zeta, the loop damping factor > ');
    fs = input('Enter the sampling frequency in Hertz > ');
    tstop = input('Enter tstop, the simulation runtime > ');
end %
npts = fs*tstop+1; % number of simulation points
t = (0:(npts-1))/fs; % default time vector
nsettle = fix(npts/10); % set nsettle time as 0.1*npts
tsettle = nsettle/fs; % set tsettle
% The next two lines establish the loop input frequency and phase
% deviations.
fin = [zeros(1,nsettle),fdel*ones(1,npts-nsettle)];
phin = [zeros(1,nsettle),2*pi*fdel*t(1:(npts-nsettle))];
disp(' ') % insert blank line
% end of script file pllpre.m

% File: pll2sin.m
w2b=0; w2c=0; s5=0; phivco=0; %initialize
twopi=2*pi; % define 2*pi
twofs=2*fs; % define 2*fs
G=2*pi*fn*(zeta+sqrt(zeta*zeta-lambda)); % set loop gain
a=2*pi*fn/(zeta+sqrt(zeta*zeta-lambda)); % set filter parameter
a1=a*(1-lambda); a2 = a*lambda; % define constants
phierror = zeros(1,npts); % initialize vector
fvco=zeros(1,npts); % initialize vector
% beginning of simulation loop
for i=1:npts
    s1=phin(i) - phivco; % phase error
    s2=sin(s1); % sinusoidal phase detector
    s3=G*s2;
    s4=a1*s3;
    s4a=s4-a2*s5; % loop filter integrator input
    w1b=s4a+w2b; % filter integrator (step 1)
    w2b=s4a+w1b; % filter integrator (step 2)
    s5=w1b/twofs; % generate fiter output
    s6=s3+s5; % VCO integrator input
    w1c=s6+w2c; % VCO integrator (step 1)
    w2c=s6+w1c; % VCO integrator (step 2)
    phivco=w1c/twofs; % generate VCO output
    phierror(i)=s1; % build phase error vector
    fvco(i)=s6/twopi; % build VCO input vector
end
% end of simulation loop
freqerror=fin-fvco; % build frequency error vector
% End of script file.



