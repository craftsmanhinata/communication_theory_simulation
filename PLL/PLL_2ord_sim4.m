%%%      2�����໷�����ļ�    %%%
%%%%          PLL_2ord_sim4.m         %%%%   

%   date: 2020-03-01    author: zjw    %%


%%%%   ����˵��
%������ʵ����֤���໷�����ݹ�ʽ��������໷
%

%%%        ���滷�� 
% ����汾��matlab 2019a
% �ź�Դ������Ƶ�ʽ�Ծ�ź�

%*****    ����ǰ׼��   *****%
clear;
close all;
clc;
format long;

%%*********       ��������        *********%%
%��������
f0 = 2e4;
fdop = 500; %������Ƶƫ
fs = 16e4; %����Ƶ��
phi0 = 30*pi*180;
phi1 = 90*pi*180;

%��·�˲����������
index = 0.707;  %��������
Bn = 300;   %��������
ts = 1/fs;  %ʱ������
wn = 2*Bn/(index+1/(4*index));
para = 4+4*index*wn*ts+(wn*ts)^2;

plus = 10;  %��·�˲�������
c1 = plus*8*index*wn*ts/para;
c2 = plus*4*(wn*ts)^2/para;

n = 10000; % n/fs �������
nn = 1:n;
slop = 500;  %Hz/s  ģ��������Ƶ�ʵĹ���Ƶ�
%signal = cos(2*pi*(f0+fdop)*nn*ts+phi0);  %lms data
signal = cos(2*pi*(f0+fdop)*nn*ts+2*pi*slop*nn*ts+phi0);  %lms data
signal1 = cos(2*pi*(f0+fdop)*2*nn*ts+2*pi*slop*nn*ts+phi1);  %lms data

signal(5000:7000) = signal1(5000:7000);%�м���΢��һ�£�Ƶ����΢ʧ��һ�¡�

signal = awgn(signal,20,'measured'); %Add white Gaussian noise.�����Ϊ-5db

figure(1);
plot(signal,'-*');
title('ԭʼ�ź�');
xlabel('ʱ��');ylabel('����ֵ');

%��ͨ�˲������
lp_fir = fir1(250,0.25);

spll = zeros(1,n);
phase = zeros(1,n);
e = zeros(1, (n-125));

for k = 1:n-125
    localsign = sin(2*pi*f0*(1:n)*ts+phase(k));
    Isign = signal(1:n).*localsign; %������
    Isign = filter(lp_fir,1,Isign);
    e(k) = Isign(k+125);
    
    if k>=2
        spll(k) = spll(k-1)+e(k)*c2;
        f(k) = c1*e(k) + spll(k);
        phase(k+1) = phase(k) + f(k);
    end
end

x = (1:(n-125))/fs;
figure(2);
plot(x,e);
%title('�������໷����ʼƵ��500hz,��������500hz')
title('�������໷����ʼƵ��500hz,��������500hz')
xlabel('ʱ��(s)');
ylabel('���');
grid on;

figure(3);
plot(localsign,'-*');
%title('�������໷����ʼƵ��500hz,��������500hz')
title('�������໷�ָ��ı����ز�����ʼƵ��500hz,��������500hz')
xlabel('ʱ��');
ylabel('����');


%����
%���໷������
%���������໷����������ͬ��.����ɽ���У����ն��Ѿ�֪���ز���Ƶ�ʡ�






