%%%      眼图仿真程序1     %%%

%%%%          sim_double_polar_NRZ_eyegraph_ex1.m         %%%%   
%   date: 2020-2-16    author: zjw %%

%%%%   程序说明
%示意双极性NRZ基带信号经过带宽受限信号造成的码间串扰影响及其眼图
%%%        仿真环境 
% 软件版本：matlab 2019a


%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%
N = 1000;
N_sample = 8;   %每个码元的抽样点数
Ts = 1;
dt = Ts/N_sample;
t = 0:dt:(N*N_sample-1)*dt;
gt = ones(1,N_sample);  %数字基带波形
d = sign(randn(1,N));   %输入数字序列
a = sigexpand(d, N_sample);
st = conv(a, gt);   %数字基带信号
ht1 = 5*sinc(5*(t-5)/Ts);
rt1 = conv(st, ht1);
ht2 = sinc((t-5)/Ts);
rt2 = conv(st, ht2);

eyediagram(rt1+1i*rt2, 40, 5);

%将输入的序列扩展成间隔为M-1个0的序列
function [out] = sigexpand(d,M)
    N = length(d);
    out = zeros(M, N);
    out(1,:) = d;
    out = reshape(out, 1, M*N);
end
    
