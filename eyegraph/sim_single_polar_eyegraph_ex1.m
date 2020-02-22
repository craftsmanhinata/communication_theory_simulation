%%%      ��ͼ�������1     %%%

%%%%          sim_single_polar_eyegraph_ex1.m         %%%%   
%   date: 2020-2-16    author: zjw %%

%%%%   ����˵��

%%%        ���滷�� 
% ����汾��matlab 2019a


%*****    ����ǰ׼��   *****%
clear;
close all;
clc;
format long;

%%*********       ��������        *********%%
nfact = 0.05;   %��������ϵ����Խ�����Խ���أ���ͼ�ſ��Ƕ�ԽС
Ts = 1;
eyenum = 10;
codenum = 4;
tsample = 4;
dt = 0.2;
t = -eyenum/2:dt:eyenum/2;

alpha = input('�������ϵ��alpha=(ȱʡΪ1)');%���������������Ϊ������
if isempty(alpha)
    alpha = 1;
end

pp = cos(alpha*pi*t/Ts);
pp1 = 1./(1-4*t.*t*alpha*alpha/Ts/Ts);
ht = 1/Ts*sinc(t/Ts).*pp.*pp1;
%ht = 1/Ts*sinc(t/Ts) + 1/Ts*sinc((t-Ts)/Ts);
code = sign(randn(1,codenum)) + nfact*randn(1, codenum);    %����+1,0�������ź�

figure(1);%����ͼ
hold on;
xlabel('Ts');ylabel('rt');
title('�����ҳ�����ͼ');
grid;
for n = 1:codenum/eyenum
    ss = zeros(1,length(ht)+Ts/dt);
    for m = 1:eyenum
        tmp = code((n-1)*eyenum+m)*ht;
        tmp1 = ss((m*Ts/dt+1):length(ss))+tmp;
        ss = [ss(1:(m*Ts/dt)) tmp1 zeros(1,Ts/dt)];
    end
    drawnow
    kk=1:length(ss);
    plot(kk*dt-dt,ss);
    hold on;
    clear ss;
    axis([5 15 -3 3]);
end
    







