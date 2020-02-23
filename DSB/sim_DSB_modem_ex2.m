%%%         ����˵��
% ����2DPSK��
% Source �� https://blog.csdn.net/hxxjxw/article/details/82666096
%%%                       ���滷�� 
% ����汾��R2019a

%*********************   ׼��   *******************
clc;
clear;
close all;

%*********************   ��ʼ����   *******************
dt=0.001; %ʱ��������
fm=1; %��Դ���Ƶ��
fc=10; %�ز�����Ƶ��
T=5; %�ź�ʱ��
t=0:dt:T;
mt=sqrt(2)*cos(2*pi*fm*t); %��Դ
figure(1)
subplot(311);
plot(t,mt);
title('�����ź�')
coss=cos(2*pi*fc*t);
subplot(312);
plot(t,coss);
title('�ز��ź�')
%N0=0.01; %���������߹������ܶ�
%DSB����
s_dsb=mt.*cos(2*pi*fc*t);
B=2*fm;
%noise=noise_nb(fc,B,N0,t);
%s_dsb=s_dsb+noise;
 
subplot(313)
plot(t,s_dsb); %����DSB�źŲ���
hold on
plot (t,mt,'r--'); %���m(t)����
hold on
plot(t,-mt,'r--');
title('DSB�����ź�');
 
 
 %DSB��ɽ��
rt=s_dsb.*cos(2*pi*fc*t);
figure(2);
subplot(311);
plot(t,rt);
title('DSB�����ź����ز��ź����')
[f,rf]=T2F(t,rt);%����Ҷ�任
[t,rt]=lpf(f,rf,fm);%��ͨ�˲�
subplot(312)
plot(t,rt);
title('������ͨ�˲�����ɽ���źŲ���');
rt=rt-mean(rt);
subplot(313)
[f,sf]=T2F(t,s_dsb);%����Ҷ�任
psf=(abs(sf).^2)/T;
plot(f,psf);
axis([-2*fc 2*fc 0 max(psf)]);
title('DSB�źŹ�����');



%�۲��źŵ�Ƶ��
% figure;plot(abs(fftshift(fft(fsk.*s2))))
% hold on;
% plot(abs((fft(st2))))

%*********************   �Զ��庯��   *******************
function [f,sf]= T2F(t,st)
%����FFT�����źŵ�Ƶ�ײ����źŵ���ʵƵ�׵ĳ����Ƚϡ�
%�ű��ļ�T2F.m�����˺���T2F�������źŵĸ���Ҷ�任��
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
%�ű��ļ�F2T.m�����˺���F2T�������źŵķ�����Ҷ�任��
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
    hf = zeros(1,length(f));%ȫ�����
    bf = [-floor( B/df ): floor( B/df )] + floor( length(f)/2 );
    hf(bf)=1;
    yf=hf.*sf;
    [t,st]=F2T(f,yf);    
    st = real(st);
end
