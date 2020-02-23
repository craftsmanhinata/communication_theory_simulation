%%%         ����˵��
% ����2DPSK��
% Source �� https://blog.csdn.net/hxxjxw/article/details/82629280

%%%                       ���滷�� 
% ����汾��R2019a

%*********************   ׼��   *******************
clc;
clear;
close all;

%*********************   ��ʼ����   *******************
i=10;
j=5000;
t=linspace(0,5,j);%0-5֮�����5000������ʸ��������[0,5]�ֳ�5000��
fc=5;%�ز�Ƶ��
fm=i/5;%��Ԫ����
B=2*fm;%�źŴ���
 
%���������ź�
a=round(rand(1,i));
%figure(4);stem(a);
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
subplot(321);
plot(t,st1);
title('������');
axis([0,5,-1,2]);
 
%��ֱ任
%��0Ϊ�ο�λ
b=zeros(1,i);%ȫ�����
if(a(1)==0)
    b(1)=0;
else
    b(1)=1;
end
for n=2:10
    if a(n)==b(n-1)
        b(n)=0;
    else
        b(n)=1;
    end
end
st1=t;
for n=1:10
    if b(n)==0
        for m=j/i*(n-1)+1:j/i*n
            st1(m)=0;
        end
    else
        for m=j/i*(n-1)+1:j/i*n
            st1(m)=1;
        end
    end
end
subplot(323);
plot(t,st1);
title('�����st1');
axis([0,5,-1,2]);
 
st2=t;
for k=1:j;
    if st1(k)==1;
        st2(k)=0;
    else
        st2(k)=1;
    end
end;
subplot(324);
plot(t,st2);
title('����뷴��st2');
axis([0,5,-1,2]);
 
%�ز��ź�
s1=sin(2*pi*fc*t);
subplot(325);
plot(s1);
title('�ز��ź�s1');
s2=sin(2*pi*fc*t+pi);%����һ����λ
subplot(326);
plot(s2);
title('�ز��ź�s2');
 
%�źŵ���
d1=st1.*s1;
d2=st2.*s2;
figure(2);
subplot(411);
plot(t,d1);
title('st1*s1');
subplot(412);
plot(t,d2);
title('st2*s2');
e_dpsk=d1+d2;
subplot(413);
plot(t,e_dpsk);
title('���ƺ���');
 
%����
noise=rand(1,j);
dpsk=e_dpsk+noise;%��������
subplot(414);
plot(t,dpsk);
title('���������ź�');
 
%��ɽ��
dpsk=dpsk.*s1;%���ز�s1���
figure(3);
subplot(411);
plot(t,dpsk);
title('���ز�s1��˺���');
 
[f,af]=T2F(t,dpsk);%����Ҷ�任
[t,dpsk]=lpf(f,af,B);%ͨ����ͨ�˲���,�˳���������
subplot(412);
plot(t,dpsk);
title('��ͨ�˲�����');
 
%�����о�
%��ֵ�г�1����ֵ�г�0
st=zeros(1,i);%%ȫ�����
for m=0:i-1
    if dpsk(1,m*500+250)<0
        st(m+1)=0;
        for j=m*500+1:(m+1)*500
            dpsk(1,j)=0;
        end
    else
        for j=m*500+1:(m+1)*500
            st(m+1)=1;
            dpsk(1,j)=1;
        end
    end
end
subplot(413);
plot(t,dpsk);
axis([0,5,-1,2]);
title('�����о�����')
 
%�뷴�任 2DPSK����
dt=zeros(1,i);%%ȫ�����
dt(1)=st(1);
for n=2:10
   % if (st(n)-st(n-1))<=0&&(st(n)-st(n-1))>-1;
    if (st(n)~=st(n-1))
        dt(n)=1;
    else
        dt(n)=0;
    end
end
st=t;
for n=1:10
    if dt(n)<1
        for m=j/i*(n-1)+1:j/i*n
            st(m)=0;
        end
    else
        for m=j/i*(n-1)+1:j/i*n
            st(m)=1;
        end
    end
end
subplot(414);
plot(t,st);
axis([0,5,-1,2]);
title('�뷴�任����');


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
