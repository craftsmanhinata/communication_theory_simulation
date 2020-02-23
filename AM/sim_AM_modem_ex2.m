%%%      AM调制解调器仿真程序2     %%%

%%%%          sim_AM_modem_ex2.m         %%%%   
%   date: 2020-2-16    author: zjw    %%



%%%%   程序说明


%%%        仿真环境 
% 软件版本：matlab 2019a



%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%
%AM调制信号的MATLAB实现
dt=0.0001;      %时间采样频谱
fc=10;             %载波中心频率
T=5;                %信号时长
N=T/dt;           %采样点个数
t=[0:N-1]*dt;    %采样点的时间序列
wc=2*pi*fc;
 
mt=sqrt(2)*cos(2*pi*t);  %信源
subplot(411);
plot(t,mt);
title('基带调制信号');
axis([0 5 -4 4]);
line([0,5],[0,0],'color','k');
%mt的最大值是sqrt(2)
A=2;
subplot(412);
plot(t,A+mt);
title('调制信号');
axis([0 5 -4 4]);
line([0,5],[0,0],'color','k');
 
sam=(A+mt).*cos(wc*t);
subplot(413);
plot(t,sam);
hold on;    %画出AM信号波形
plot(t,A+mt,'r-');
title('AM调制信号及其包络 A=2');
line([0,5],[0,0],'color','k');
A=1;
sam=(A+mt).*cos(wc*t);
subplot(414);
plot(t,sam);
hold on;    %画出AM信号波形
plot(t,A+mt,'r-');
title('AM调制信号及其包络 A=1(混叠)');
line([0,5],[0,0],'color','k');


