%%%      2阶锁相环仿真文件    %%%
%%%%          PLL_2ord_sim4.m         %%%%   

%   date: 2020-03-01    author: zjw    %%


%%%%   程序说明
%本程序实验验证锁相环，根据公式来设计锁相环
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
%参数设置
f0 = 2e4;
fdop = 500; %多普勒频偏
fs = 16e4; %采样频率
phi0 = 30*pi*180;
phi1 = 90*pi*180;

%环路滤波器参数设计
index = 0.707;  %阻尼因子
Bn = 300;   %噪声带宽
ts = 1/fs;  %时间周期
wn = 2*Bn/(index+1/(4*index));
para = 4+4*index*wn*ts+(wn*ts)^2;

plus = 10;  %环路滤波器增益
c1 = plus*8*index*wn*ts/para;
c2 = plus*4*(wn*ts)^2/para;

n = 10000; % n/fs 秒的数据
nn = 1:n;
slop = 500;  %Hz/s  模拟振荡器与频率的固有频差？
%signal = cos(2*pi*(f0+fdop)*nn*ts+phi0);  %lms data
signal = cos(2*pi*(f0+fdop)*nn*ts+2*pi*slop*nn*ts+phi0);  %lms data
signal1 = cos(2*pi*(f0+fdop)*2*nn*ts+2*pi*slop*nn*ts+phi1);  %lms data

signal(5000:7000) = signal1(5000:7000);%中间稍微变一下，频率稍微失锁一下。

signal = awgn(signal,20,'measured'); %Add white Gaussian noise.信噪比为-5db

figure(1);
plot(signal,'-*');
title('原始信号');
xlabel('时间');ylabel('幅度值');

%低通滤波器设计
lp_fir = fir1(250,0.25);

spll = zeros(1,n);
phase = zeros(1,n);
e = zeros(1, (n-125));

for k = 1:n-125
    localsign = sin(2*pi*f0*(1:n)*ts+phase(k));
    Isign = signal(1:n).*localsign; %鉴相器
    Isign = filter(lp_fir,1,Isign);
    e(k) = Isign(k+125);
    
    if k>=2
        spll(k) = spll(k-1)+e(k)*c2;
        f(k) = c1*e(k) + spll(k);
        phase(k+1) = phase(k) + f(k);
    end
end

x = (1:(n-125))/fs;
figure(2);
plot(x,e);
%title('二阶锁相环，初始频差500hz,噪声带宽500hz')
title('二阶锁相环，初始频差500hz,噪声带宽500hz')
xlabel('时间(s)');
ylabel('相差');
grid on;

figure(3);
plot(localsign,'-*');
%title('二阶锁相环，初始频差500hz,噪声带宽500hz')
title('二阶锁相环恢复的本地载波，初始频差500hz,噪声带宽500hz')
xlabel('时间');
ylabel('幅度');


%结论
%锁相环结束。
%深刻理解锁相环是用来产生同相.在相干解调中，接收端已经知道载波的频率。






