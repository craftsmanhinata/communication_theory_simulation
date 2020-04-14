%%%      2�����໷�����ļ�    %%%
%%%%          PLL_2ord_sim1.m         %%%%   

%   date: 2020-02-29    author: zjw    %%


%%%%   ����˵��
%������ʵ��MATLAB�����ļ��и�����8PSK��ʹ�÷ŷ�
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
Fs = 1.2e4; %����Ƶ��
%����Ƶ�����ӣ�����Ч������
T = 1/Fs;   %��������
tend= T*3000; %��ʱ��3000��
f0 = 0;
t = 0:T:tend-T;%3000��Ĳ���ʱ��
t1 = tend:T:2*tend;%���ŵ�3001��
num = 2*length(t);  %��������ݵ���
%һ��Ƶ�ʽ�Ծ���ź�Դ
fstep = 1000; %Ƶ�ʱ仯 100Hz/s 500Hz/s
phase1 = 2*pi*f0.*t + 2*pi*fstep.*t.*t;
% phase2 = phase1(3000) + 2*pi*f0.*t1 + 2*pi*fstep.*t1.*t1;
phase2 = 2*pi*fstep.*(tend-T).*(tend-T) + 2*pi*f0.*t1 - 2*pi*fstep.*t1.*t1;
phase = [phase1 phase2];
figure;
subplot(3,1,1),plot(mod(phase,2*pi));
title('ԭʼ�ź�');
subplot(3,1,2),plot(diff(phase(1:2000)));
title('�ź�Ƶ�������׶�');
ylabel('�ź�Ƶ��');
subplot(3,1,3),plot(diff(phase(4000:5000))*Fs);
title('�ź�Ƶ���½��׶�');
%�źŴ�����λͻ�������
%��λ����ʱ���΢С�仯����ӳ����Ƶ�����ˡ�
%��λ��������Ӧ��Ƶ�����ӣ�����Խ��Ƶ�������ٶ�Խ��
%��λ������������Ƶ�ʽ��ͣ�����Խ��Ƶ�ʽ����ٶ�Խ��


%���໷
Bn = 100;   %������Ч���� ��λHz
a = 1.1;
b = 2.4;
Wn = 4*Bn/((a*b^2+a^2-b)/(a*b-1));

%%*********       result        *********%%
%           Bn=1,T=1e-3;      Bn=5,T=1e-3;      Bn=10,T=1e-3;
%�������      û������           ��������ϲ�         �����������
%           Bn=20,T=1e-3;     Bn=100,T=1e-3;    Bn=250,T=1e-3;
%�������     ��������ǳ���      ��������ǳ���        �����������
%           Bn=200,T=1e-2;    Bn=200,T=1e-4;    Bn=200,T=1e-5;
%�������       û������          ��������ǳ���       ��������ϲ�
%           Bn=1000,T=1e-3;   
%�������      �����������      

A = zeros(1,num);
B = zeros(1,num);
C = zeros(1,num);

phase_in = 2*pi*(f0-3e3).*[t t1];  %����Ƶ����2.4574e6 Hz???������

for i = 2:num-1  %
    error(i) = phase(i)-(phase_in(i)+C(i)); %������
    A(i) = A(i-1)+error(i)*Wn^3*T;  %�������ۼӣ�A
    B(i) = B(i-1)+T*(A(i)+A(i-1))*0.5+error(i)*1.1*Wn^2*T;  %��·�˲���
    C(i+1) = C(i)+T*(B(i)+B(i-1))*0.5+error(i)*2.4*Wn*T;    %NCO
end

pp = phase_in(1:6000)+C;
figure;
plot(1:num,phase(1:6000),'k',1:num,pp,'r');
title('��λ���ٽ��');
%plot(1:num/2,f(1:num/2),'k',1:num/2,fin(1:num/2),'r');
figure;
plot(error);
title('���໷����ź�');







