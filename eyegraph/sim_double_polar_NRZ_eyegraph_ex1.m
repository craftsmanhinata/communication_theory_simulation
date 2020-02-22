%%%      ��ͼ�������1     %%%

%%%%          sim_double_polar_NRZ_eyegraph_ex1.m         %%%%   
%   date: 2020-2-16    author: zjw %%

%%%%   ����˵��
%ʾ��˫����NRZ�����źž������������ź���ɵ���䴮��Ӱ�켰����ͼ
%%%        ���滷�� 
% ����汾��matlab 2019a


%*****    ����ǰ׼��   *****%
clear;
close all;
clc;
format long;

%%*********       ��������        *********%%
N = 1000;
N_sample = 8;   %ÿ����Ԫ�ĳ�������
Ts = 1;
dt = Ts/N_sample;
t = 0:dt:(N*N_sample-1)*dt;
gt = ones(1,N_sample);  %���ֻ�������
d = sign(randn(1,N));   %������������
a = sigexpand(d, N_sample);
st = conv(a, gt);   %���ֻ����ź�
ht1 = 5*sinc(5*(t-5)/Ts);
rt1 = conv(st, ht1);
ht2 = sinc((t-5)/Ts);
rt2 = conv(st, ht2);

eyediagram(rt1+1i*rt2, 40, 5);

%�������������չ�ɼ��ΪM-1��0������
function [out] = sigexpand(d,M)
    N = length(d);
    out = zeros(M, N);
    out(1,:) = d;
    out = reshape(out, 1, M*N);
end
    
