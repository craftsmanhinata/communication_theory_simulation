%%%         程序说明
% 仿真2FSK。

%%%                       仿真环境 
% 软件版本：R2019a
clc;
clear;
close all;

%-----         程序主体      --------%
%信源
Fc = 150;   %载频
Fs = 40;    %系统采样频率
Fd = 1; %码速率
N = Fs/Fd;  %
df = 10;
numSymb = 25;   %进行仿真的信息代码个数
M = 2;  %进制数
SNRpBit = 60;   %信噪比
SNR = SNRpBit/log2(M); %60?????
seed = [12345 54321];

numPlot = 15;
x = randsrc(numSymb, 1, [0:M-1]);   %产生25个二进制随机码

figure(1);
stem([0:numPlot-1], x(1:numPlot), 'bx');%显示15个码元，杆图，从x的前15个随机数中选取
title('二进制随机序列');
xlabel('Time');
ylabel('Amplitude');

%调制
y = dmod(x,Fc,Fd,Fs,'fsk',M,df);    %数字带通调制
numModPlot =numPlot*Fs; %15*40
t = (0:numModPlot-1)./Fs;   %仿真时间

figure(2);
plot(t,y(1:length(t)),'b-');
axis([min(t) max(t) -1.5 1.5]);
title('调制之后的信号');
xlabel('Time');
ylabel('Amplitude');

%在已调信号中加入高斯白噪声
randn('state',seed(2)); %生成-2到+2之间的随机数矩阵
y = awgn(y,SNR-10*log10(0.5)-10*log10(N), 'measured',[], 'dB');%在已调信号中加入高斯白噪声
figure(3);
plot(t,y(1:length(t)),'b-');%画出经过信道的实际信号
axis([min(t) max(t) -1.5 1.5]);
title('加入高斯白噪声后的已调信号');
xlabel('Time');
ylabel('Amplitude');

%相干解调
figure(4);
z1 = ddemod(y,Fc,Fd,Fs,'fsk',M,df);

%带输出波形的相干M元频移键控解调
stem((0:numPlot-1),x(1:numPlot),'bx');
hold on;
stem((0:numPlot-1),z1(1:numPlot),'ro');
hold off;
axis([0 numPlot -0.5 1.5]);
title('相干解调后信号原序列比较');
legend('原输入二进制随机序列','相干解调后的信号');
xlabel('Time');
ylabel('Amplitude');

%非相干解调
figure(6)
z2 = ddemod(y,Fc,Fd,Fs,'fsk',M,df);

%带输出波形的非相干M元频移键控解调
stem((0:numPlot-1),x(1:numPlot),'bx');
hold on;
stem((0:numPlot-1),z2(1:numPlot),'ro');
hold off;
axis([0 numPlot -0.5 1.5]);
title('相干解调后信号原序列比较');
legend('原输入二进制随机序列','相干解调后的信号');
xlabel('Time');
ylabel('Amplitude');


figure(7);
f = fftshift(fft(x,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('随机信号的频谱');
xlabel('频率（Hz）');

figure(8);
f = fftshift(fft(y,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('调制信号的频谱');
xlabel('频率（Hz）');

figure(9);
f = fftshift(fft(z1,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('调制信号的频谱');
xlabel('频率（Hz）');

figure(10);
f = fftshift(fft(z2,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('调制信号的频谱');
xlabel('频率（Hz）');














