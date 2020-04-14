%%%      2阶锁相环仿真文件    %%%
%%%%          PLL_2ord_sim1.m         %%%%   

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
Fs = 1.2e4; %采样频率
%采样频率增加，跟踪效果变差？？
T = 1/Fs;   %采样周期
tend= T*3000; %总时长3000点
f0 = 0;
t = 0:T:tend-T;%3000点的采样时刻
t1 = tend:T:2*tend;%接着的3001点
num = 2*length(t);  %处理的数据点数
%一个频率阶跃的信号源
fstep = 1000; %频率变化 100Hz/s 500Hz/s
phase1 = 2*pi*f0.*t + 2*pi*fstep.*t.*t;
% phase2 = phase1(3000) + 2*pi*f0.*t1 + 2*pi*fstep.*t1.*t1;
phase2 = 2*pi*fstep.*(tend-T).*(tend-T) + 2*pi*f0.*t1 - 2*pi*fstep.*t1.*t1;
phase = [phase1 phase2];
figure;
subplot(3,1,1),plot(mod(phase,2*pi));
title('原始信号');
subplot(3,1,2),plot(diff(phase(1:2000)));
title('信号频率上升阶段');
ylabel('信号频率');
subplot(3,1,3),plot(diff(phase(4000:5000))*Fs);
title('信号频率下降阶段');
%信号存在相位突变情况！
%相位随着时间的微小变化均反映在了频率上了。
%相位正增量对应着频率增加，增量越大频率增加速度越快
%相位负增量代表着频率降低，增量越大频率降低速度越快


%锁相环
Bn = 100;   %噪声等效带宽 单位Hz
a = 1.1;
b = 2.4;
Wn = 4*Bn/((a*b^2+a^2-b)/(a*b-1));

%%*********       result        *********%%
%           Bn=1,T=1e-3;      Bn=5,T=1e-3;      Bn=10,T=1e-3;
%跟踪情况      没跟踪上           跟踪情况较差         跟踪情况良好
%           Bn=20,T=1e-3;     Bn=100,T=1e-3;    Bn=250,T=1e-3;
%跟踪情况     跟踪情况非常好      跟踪情况非常好        跟踪情况良好
%           Bn=200,T=1e-2;    Bn=200,T=1e-4;    Bn=200,T=1e-5;
%跟踪情况       没跟踪上          跟踪情况非常好       跟踪情况较差
%           Bn=1000,T=1e-3;   
%跟踪情况      跟踪情况良好      

A = zeros(1,num);
B = zeros(1,num);
C = zeros(1,num);

phase_in = 2*pi*(f0-3e3).*[t t1];  %本振频率是2.4574e6 Hz???、存疑

for i = 2:num-1  %
    error(i) = phase(i)-(phase_in(i)+C(i)); %鉴相器
    A(i) = A(i-1)+error(i)*Wn^3*T;  %这里在累加，A
    B(i) = B(i-1)+T*(A(i)+A(i-1))*0.5+error(i)*1.1*Wn^2*T;  %环路滤波器
    C(i+1) = C(i)+T*(B(i)+B(i-1))*0.5+error(i)*2.4*Wn*T;    %NCO
end

pp = phase_in(1:6000)+C;
figure;
plot(1:num,phase(1:6000),'k',1:num,pp,'r');
title('相位跟踪结果');
%plot(1:num/2,f(1:num/2),'k',1:num/2,fin(1:num/2),'r');
figure;
plot(error);
title('锁相环误差信号');







