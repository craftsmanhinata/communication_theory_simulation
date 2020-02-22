%%%         程序说明
% 仿真2ASK。

%%%                       仿真环境 
% 软件版本：R2019a
clc;
clear;
close all;

%-----         程序主体      --------%
%信源
a = randi([0,1], 1, 15);
t = 0:0.001:0.999;
m = a(ceil(15*t+0.01));

subplot(5,1,1);
plot(t,m);
axis([0 1.2 -0.2 1.2]);
title('信源');

%载波
f = 150;
carry = cos(2*pi*f*t);
%2ASK
st = m.*carry;
subplot(5,1,2);
plot(t, st);
axis([0 1.2 -1.2 1.2]);
title('2ASK信号');

%加高斯信号
nst = awgn(st, 20);

%解调
nst = nst.*carry;
subplot(5,1,3);
plot(t, nst);
axis([0 1.2 -0.2 1.2]);
title('乘以相干载波后的信号');

%设计低通滤波器
wp = 2*pi*2*f*0.5;
ws = 2*pi*2*f*0.9;
Rp = 2;
As = 45;
[N,wc] = buttord(wp, ws, Rp, As, 's');
[B,A] = butter(N, wc, 's'); %低通滤波
h = tf(B,A);    %转换称为传输函数
dst = lsim(h,nst,t);
subplot(5,1,4);
plot(t,dst);
axis([0 1.2 -0.2 1.2]);
title('经过低通滤波器后的信号');


%判决器
k = 0.25;
pdst = 1*(dst>0.25);
% ppdst = lsim(h,pdst,t);
% pppdst = 1*(ppdst>0.5);
subplot(5,1,5);
plot(t,pdst);
axis([0 1.2 -0.2 1.2]);
title('经过抽样判决后的信号');

%频谱观察 调制信号频谱
T = t(end);
df = 1/T;
N = length(st);
f = (-N/2:N/2-1)*df;
sf = fftshift(abs(fft(st)));
figure(2);
subplot(4,1,1);
plot(f,sf);
title('调制信号的频谱')

%信源频谱
mf = fftshift(abs(fft(m)));
subplot(4,1,2);
plot(f, mf);
title('信源频谱');
%乘以相干载波后的频谱
mmf = fftshift(abs(fft(nst)));
subplot(4,1,3);
plot(f,mmf);
title('乘以相干载波后的频谱');
%经过低通滤波器后的频谱
dmf = fftshift(abs(fft(pdst)));
subplot(4,1,4);
plot(f,dmf);
title('经过低通滤波后的频谱');

