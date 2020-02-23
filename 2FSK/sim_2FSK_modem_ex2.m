%%%         ����˵��
% ����2FSK��
% Source �� https://blog.csdn.net/hxxjxw/article/details/82629113

%%%                       ���滷�� 
% ����汾��R2019a

%*********************   ׼��   *******************
clc;
clear;
close all;

%*********************   ��ʼ����   *******************
i=10;%�����ź���Ԫ��
j=5000;
t=linspace(0,5,j);%0-5֮�����5000������ʸ��������[0,5]�ֳ�5000��
f1=10;%�ز�1Ƶ��
f2=5;%�ز�2Ƶ��
fm=i/5;%�����ź�Ƶ��    ��Ԫ����10����ʱ�򳤶���5��Ҳ����һ����λ2����Ԫ

noise_pow = 20;

a=round(rand(1,i));%����������У�0��1����
 
%���������ź�
st1=t;
for n=1:10
    if a(n)<1
        for m=j/i*(n-1)+1:j/i*n
            st1(m)=0;
        end
    else
        for m=j/i*(n-1)+1:j/i*n
            st1(m)=1;
        end
    end
end
 
figure(1);
subplot(411);
plot(t,st1);
title('�����ź�st1');
axis([0,5,-1,2]);
 
%�����ź���
st2=t;
for n=1:j
    if st1(n)==1
        st2(n)=0;
    else
        st2(n)=1;
    end
end
subplot(412);
plot(t,st2);
title('�����źŷ���st2');
axis([0,5,-1,2]);
 
%�ز��ź�
s1=cos(2*pi*f1*t);
s2=cos(2*pi*f2*t);
subplot(413),plot(s1);
title('�ز��ź�s1');
subplot(414),plot(s2);
title('�ز��ź�s2');
 
%����
F1=st1.*s1;%�����ز�1
F2=st2.*s2;%�����ز�2
figure(2);
subplot(411);
plot(t,F1);
title('F1=s1*st1');
subplot(412);
plot(t,F2);
title('F2=s2*st2');
e_fsk=F1+F2;
subplot(413);
plot(t,e_fsk);
title('2FSK�ź�');%���ط��������ź���������Ԫ֮����λ��һ������
 
%����
nosie=noise_pow*rand(1,j);
fsk=e_fsk+nosie;
subplot(414);
plot(t,fsk);
title('���������ź�')
 
%��ɽ��
std1=fsk.*s1; %���ز�1���
[f,sfd1] = T2F(t,std1);%����Ҷ�任
[t,std1] = lpf(f,sfd1,2*fm);%ͨ����ͨ�˲���
figure(3);
subplot(411);
plot(t,std1);
title('�������ź���s1��˺���');
std2=fsk.*s2;%���ز�2���
[f,sfd2] = T2F(t,std2);%ͨ����ͨ�˲���
[t,std2] = lpf(f,sfd2,2*fm);
subplot(412);
plot(t,std2);
title('�������ź���s2��˺���');
 
%�����о�
for m=0:i-1
    if st1(1,m*500+250)>st2(1,m*500+250)
        for j=m*500+1:(m+1)*500
            at(1,j)=1;
        end
    else
        for j=m*500+1:(m+1)*500
            at(1,j)=0;
        end
    end
end
subplot(413);
plot(t,at);
axis([0,5,-1,2]);
title('�����о�����')
subplot(414);
plot(t,st1);
title('�����ź�st1');
axis([0,5,-1,2]);

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
