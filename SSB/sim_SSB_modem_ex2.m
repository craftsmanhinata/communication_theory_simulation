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
fm=10;fc=40;
am=sqrt(2);
Fs=300;     %����Ƶ��Fs���ز�Ƶ��fc���ź�Ƶ��fm
wc=2*pi*fc;
wm=fm*2*pi;
N=300;
n=0:N-1;
t=n/Fs;             %ʱ������
f=n*Fs/N;
 
%�����ź�ʱ��
sm=am*cos(wm*t);
figure(1);
subplot(211);
plot(t,sm);
title('�����ź�');
xlabel('t');
axis([0 1 -2 2]);
grid on
 
%�����ź�Ƶ��
S=fft(sm,300);%300���fft
SG=abs(S);
subplot(212);
plot(f(1:N/2),SG(1:N/2));      %SSB�ź�Ƶ����
xlabel('Frequency(HZ)');
title('�����ź�Ƶ���� ');
grid on;
 
%SSB�����ź�ʱ��
s=modulate(sm,fc,Fs,'amssb');       %�Ե����źŽ��е���
S=fft(s,300);
SG=abs(S);
figure(2);
subplot(211);
plot(t,s);                          %SSB�ź�ʱ����
title('SSB�ź�ʱ���� ');        
xlabel('t');
 
subplot(212);
plot(f(1:N/2),SG(1:N/2));            %SSB�ź�Ƶ����
xlabel('Frequency(HZ)');
title('SSB�ź�Ƶ���� ');
grid on;
 
%-------------------------------------------------------------------------
%���
fm=10;%�ź�Ƶ��fm
fc=40;%�ز�Ƶ��fc
am=sqrt(2);
Fs=300;     %����Ƶ��Fs
wc=2*pi*fc;
wm=fm*2*pi;
N=300;
n=0:N-1;
t=n/Fs;      %ʱ������
f=n*Fs/N;
sm=am*cos(wm*t);
s=modulate(sm,fc,Fs,'amssb');  
sd=demod(s,fc,Fs,'amssb');         %��SSB�źŽ��н��
SD=fft(sd,300);
SDG=abs(SD);
figure(3);
subplot(2,1,1);
plot(t,sd);                              %������ʱ����
title('������ʱ����');
xlabel('t');
axis([0 1 -2 2]);
subplot(2,1,2);
plot(f(1:N/2),SDG(1:N/2));             %������Ƶ����
title('������Ƶ����');
xlabel('Frequency(HZ)');
axis([0 150 0 300]);
grid on;


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
