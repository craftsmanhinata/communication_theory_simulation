%%%         程序说明
% 仿真2DPSK。
% Source ： https://blog.csdn.net/hxxjxw/article/details/82666096
%%%                       仿真环境 
% 软件版本：R2019a

%*********************   准备   *******************
clc;
clear;
close all;

%*********************   开始仿真   *******************
dt=0.001; %时间采样间隔
fm=1; %信源最高频率
fc=10; %载波中心频率
T=5; %信号时长
t=0:dt:T;
mt=sqrt(2)*cos(2*pi*fm*t); %信源
figure(1)
subplot(311);
plot(t,mt);
title('调制信号')
coss=cos(2*pi*fc*t);
subplot(312);
plot(t,coss);
title('载波信号')
%N0=0.01; %白噪声单边功率谱密度
%DSB调制
s_dsb=mt.*cos(2*pi*fc*t);
B=2*fm;
%noise=noise_nb(fc,B,N0,t);
%s_dsb=s_dsb+noise;
 
subplot(313)
plot(t,s_dsb); %画出DSB信号波形
hold on
plot (t,mt,'r--'); %标出m(t)波形
hold on
plot(t,-mt,'r--');
title('DSB调制信号');
 
 
 %DSB相干解调
rt=s_dsb.*cos(2*pi*fc*t);
figure(2);
subplot(311);
plot(t,rt);
title('DSB调制信号与载波信号相乘')
[f,rf]=T2F(t,rt);%傅里叶变换
[t,rt]=lpf(f,rf,fm);%低通滤波
subplot(312)
plot(t,rt);
title('经过低通滤波的相干解调信号波形');
rt=rt-mean(rt);
subplot(313)
[f,sf]=T2F(t,s_dsb);%傅里叶变换
psf=(abs(sf).^2)/T;
plot(f,psf);
axis([-2*fc 2*fc 0 max(psf)]);
title('DSB信号功率谱');



%观察信号的频谱
% figure;plot(abs(fftshift(fft(fsk.*s2))))
% hold on;
% plot(abs((fft(st2))))

%*********************   自定义函数   *******************
function [f,sf]= T2F(t,st)
%利用FFT计算信号的频谱并与信号的真实频谱的抽样比较。
%脚本文件T2F.m定义了函数T2F，计算信号的傅立叶变换。
%Input is the time and the signal vectors,the length of time must greater
%than 2
%Output is the frequency and the signal spectrum
    dt = t(2)-t(1);
    T=t(end);
    df = 1/T;
    N = length(st);
    f=-N/2*df : df : N/2*df-df;
    sf = fft(st);
    sf = T/N*fftshift(sf);
end

function [t,st]=F2T(f,sf)
%脚本文件F2T.m定义了函数F2T，计算信号的反傅立叶变换。
%This function calculate the time signal using ifft function for the input
    df = f(2)-f(1);
    Fmx = ( f(end)-f(1) +df);
    dt = 1/Fmx;
    N = length(sf);
    T = dt*N;
    %t=-T/2:dt:T/2-dt;
    t = 0:dt:T-dt;
    st = Fmx*ifft(sf);
end


function [t,st]=lpf(f,sf,B)
%This function filter an input data using a lowpass filter
%Inputs: f: frequency samples
% sf: input data spectrum samples
% B: lowpass bandwidth with a rectangle lowpass
%Outputs: t: time samples
% st: output data time samples
    df = f(2)-f(1);
    T = 1/df;
    hf = zeros(1,length(f));%全零矩阵
    bf = [-floor( B/df ): floor( B/df )] + floor( length(f)/2 );
    hf(bf)=1;
    yf=hf.*sf;
    [t,st]=F2T(f,yf);    
    st = real(st);
end
