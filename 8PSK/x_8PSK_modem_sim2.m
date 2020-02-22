%%%      8PSK���ƽ�����������ܷ������1     %%%
%%%%          8PSK_modem_sim2.m         %%%%   

%   date: 2020-02-15    author: zjw    %%


%%%%   ����˵��
%������ʵ��MATLAB�����ļ��и�����8PSK��ʹ�÷ŷ�
%��Ҫ��ʵ��pskmod��ʹ�÷���

%%%        ���滷�� 
% ����汾��matlab 2019a

clc;
clear;
close all;

%Set the modulation order to 4.
M = 2;
snr = 3;

%Generate random data symbols.
data = randi([0 M-1],1000,1);

%Modulate the data symbols.
txSig = pskmod(data,M,pi/M);

%Pass the signal through white noise and plot its constellation.
rxSig = awgn(txSig,snr);
%scatterplot(txSig)
scatterplot(rxSig)

% Demodulate the received signal and compute the number of symbol errors.
dataOut = pskdemod(rxSig,M,pi/M);
numErrs = symerr(data,dataOut)

fprintf('������� = %d\n', numErrs);
fprintf('������� = %f\n', numErrs/1000);

