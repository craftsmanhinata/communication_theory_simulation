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
fm=10;fc=40;
am=sqrt(2);
Fs=300;     %采样频率Fs，载波频率fc，信号频率fm
wc=2*pi*fc;
wm=fm*2*pi;
N=300;
n=0:N-1;
t=n/Fs;             %时间序列
f=n*Fs/N;
 
%基带信号时域
sm=am*cos(wm*t);
figure(1);
subplot(211);
plot(t,sm);
title('基带信号');
xlabel('t');
axis([0 1 -2 2]);
grid on
 
%基带信号频域
S=fft(sm,300);%300点的fft
SG=abs(S);
subplot(212);
plot(f(1:N/2),SG(1:N/2));      %SSB信号频域波形
xlabel('Frequency(HZ)');
title('基带信号频域波形 ');
grid on;
 
%SSB调制信号时域
s=modulate(sm,fc,Fs,'amssb');       %对调制信号进行调制
S=fft(s,300);
SG=abs(S);
figure(2);
subplot(211);
plot(t,s);                          %SSB信号时域波形
title('SSB信号时域波形 ');        
xlabel('t');
 
subplot(212);
plot(f(1:N/2),SG(1:N/2));            %SSB信号频域波形
xlabel('Frequency(HZ)');
title('SSB信号频域波形 ');
grid on;
 
%-------------------------------------------------------------------------
%解调
fm=10;%信号频率fm
fc=40;%载波频率fc
am=sqrt(2);
Fs=300;     %采样频率Fs
wc=2*pi*fc;
wm=fm*2*pi;
N=300;
n=0:N-1;
t=n/Fs;      %时间序列
f=n*Fs/N;
sm=am*cos(wm*t);
s=modulate(sm,fc,Fs,'amssb');  
sd=demod(s,fc,Fs,'amssb');         %对SSB信号进行解调
SD=fft(sd,300);
SDG=abs(SD);
figure(3);
subplot(2,1,1);
plot(t,sd);                              %解调后的时域波形
title('解调后的时域波形');
xlabel('t');
axis([0 1 -2 2]);
subplot(2,1,2);
plot(f(1:N/2),SDG(1:N/2));             %解调后的频域波形
title('解调后的频域波形');
xlabel('Frequency(HZ)');
axis([0 150 0 300]);
grid on;


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
