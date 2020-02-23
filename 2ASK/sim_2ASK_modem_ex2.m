%%%         ����˵��
% ����2ASK��
% Source �� https://blog.csdn.net/hxxjxw/article/details/82628565

%%%                       ���滷�� 
% ����汾��R2019a

%**********************   ׼��   *******************
clc; 
clear;
close all;

%*********************   ��ʼ����   *******************
i=10;%10����Ԫ
j=5000;
t=linspace(0,5,j);%0-5֮�����5000������ʸ��������[0,5]�ֳ�5000��
fc=10;%�ز�Ƶ��
fm=i/5;%��Ԫ����
%���������ź�
x=(rand(1,i));%rand����������0-1֮�����������1-10��
%figure(2)l;plot(x);
a=round(x);%������У�roundȡ��ӽ�С��������
%>0.5��ֵ��Ϊ1��<0.5��ֵ��Ϊ0
%figure(3);stem(a);%���״ͼ
 
st=t;
for n=1:10
    if a(n)<1
        disp(j/i*(n-1))
        for m=j/i*(n-1)+1:j/i*n  %a(1)��1�Ļ�,�ͽ�0-1��ֵΪ1
            st(m)=0;
        end
    else
        for m=j/i*(n-1)+1:j/i*n
            st(m)=1;
        end
    end
end
figure(1);
subplot(421);
plot(t,st);
 
axis([0,5,-1,2]);
title('�����ź�st');
%�ز�
s1=cos(2*pi*fc*t);
subplot(422);
plot(s1);
title('�ز��ź�s1');
 
%����
e_2ask=st.*s1;%st�ǻ����ź�,s1���ز�
subplot(423);
plot(t,e_2ask);
title('�ѵ��ź�');
 
noise =rand(1,j);
e_2ask=e_2ask+noise;%��������
subplot(424);
plot(t,e_2ask);
title('�����������ź�');
 
%��ɽ��
at=e_2ask.*cos(2*pi*fc*t);%�����õ�cos������ز�s1��ȫͬ��
%subplot(428);plot(t,at);
at=at-mean(at);%��Ϊ�ǵ����Բ��Σ�����ֱ��������Ӧȥ��
subplot(425);
plot(t,at);
title('���ز���˺��ź�');
 
[f,af] = T2F(t,at);%ͨ����ͨ�˲���
[t,at] = lpf(f,af,2*fm);
subplot(426);
plot(t,at);
title('��ɽ������');
 
%����ɽ��
de_2ask1 = e_2ask - mean(e_2ask);   %ȥֱ������
de_2ask2 = abs(de_2ask1);   %ȫ������ 
[f1,af1] = T2F(t,de_2ask2);%ͨ����ͨ�˲���
[t2,at2] = lpf(f1,af1,2*fm);
subplot(427);
plot(t2,at2);
title('����ɽ������');



%�����о�
for m=0:i-1 %i=10   i����Ԫ����
    if (at(1,m*500+250)+0.5)<0.5%500��1����Ԫ�ĳ��ȣ�+250��������ÿ�ζ���λ��ÿ����Ԫ�в�
        for j=m*500+1:(m+1)*500%����о���λ��Ԫ��ֵ<0.5,��ô�����Ԫ��Ϊ0
            at(1,j)=0;
        end
    else
        for j=m*500+1:(m+1)*500
            at(1,j)=1;%������Ϊ1
        end
    end
end
subplot(428);
plot(t,at);
axis([0,5,-1,2]);
title('�����о�����')

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
    sff = fftshift(sf);
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


