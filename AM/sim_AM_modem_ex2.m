%%%      AM���ƽ�����������2     %%%

%%%%          sim_AM_modem_ex2.m         %%%%   
%   date: 2020-2-16    author: zjw    %%



%%%%   ����˵��


%%%        ���滷�� 
% ����汾��matlab 2019a



%*****    ����ǰ׼��   *****%
clear;
close all;
clc;
format long;

%%*********       ��������        *********%%
%AM�����źŵ�MATLABʵ��
dt=0.0001;      %ʱ�����Ƶ��
fc=10;             %�ز�����Ƶ��
T=5;                %�ź�ʱ��
N=T/dt;           %���������
t=[0:N-1]*dt;    %�������ʱ������
wc=2*pi*fc;
 
mt=sqrt(2)*cos(2*pi*t);  %��Դ
subplot(411);
plot(t,mt);
title('���������ź�');
axis([0 5 -4 4]);
line([0,5],[0,0],'color','k');
%mt�����ֵ��sqrt(2)
A=2;
subplot(412);
plot(t,A+mt);
title('�����ź�');
axis([0 5 -4 4]);
line([0,5],[0,0],'color','k');
 
sam=(A+mt).*cos(wc*t);
subplot(413);
plot(t,sam);
hold on;    %����AM�źŲ���
plot(t,A+mt,'r-');
title('AM�����źż������ A=2');
line([0,5],[0,0],'color','k');
A=1;
sam=(A+mt).*cos(wc*t);
subplot(414);
plot(t,sam);
hold on;    %����AM�źŲ���
plot(t,A+mt,'r-');
title('AM�����źż������ A=1(���)');
line([0,5],[0,0],'color','k');


