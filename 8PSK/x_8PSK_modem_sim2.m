%%%      8PSK调制解调器误码性能仿真程序1     %%%
%%%%          8PSK_modem_sim2.m         %%%%   

%   date: 2020-02-15    author: zjw    %%


%%%%   程序说明
%本程序实验MATLAB帮助文件中给出的8PSK的使用放法
%主要是实验pskmod的使用方法

%%%        仿真环境 
% 软件版本：matlab 2019a

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

fprintf('误符号数 = %d\n', numErrs);
fprintf('误符号率 = %f\n', numErrs/1000);

