%%%      眼图仿真程序1     %%%

%%%%          sim_single_polar_eyegraph_ex1.m         %%%%   
%   date: 2020-2-16    author: zjw %%

%%%%   程序说明

%%%        仿真环境 
% 软件版本：matlab 2019a


%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%
nfact = 0.05;   %噪声干扰系数，越大干扰越严重，眼图张开角度越小
Ts = 1;
eyenum = 10;
codenum = 4;
tsample = 4;
dt = 0.2;
t = -eyenum/2:dt:eyenum/2;

alpha = input('输入滚降系数alpha=(缺省为1)');%定义基带传输脉冲为升余弦
if isempty(alpha)
    alpha = 1;
end

pp = cos(alpha*pi*t/Ts);
pp1 = 1./(1-4*t.*t*alpha*alpha/Ts/Ts);
ht = 1/Ts*sinc(t/Ts).*pp.*pp1;
%ht = 1/Ts*sinc(t/Ts) + 1/Ts*sinc((t-Ts)/Ts);
code = sign(randn(1,codenum)) + nfact*randn(1, codenum);    %产生+1,0的数字信号

figure(1);%画眼图
hold on;
xlabel('Ts');ylabel('rt');
title('升余弦成形眼图');
grid;
for n = 1:codenum/eyenum
    ss = zeros(1,length(ht)+Ts/dt);
    for m = 1:eyenum
        tmp = code((n-1)*eyenum+m)*ht;
        tmp1 = ss((m*Ts/dt+1):length(ss))+tmp;
        ss = [ss(1:(m*Ts/dt)) tmp1 zeros(1,Ts/dt)];
    end
    drawnow
    kk=1:length(ss);
    plot(kk*dt-dt,ss);
    hold on;
    clear ss;
    axis([5 15 -3 3]);
end
    







