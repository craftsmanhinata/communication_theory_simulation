%%%      QPSK调制解调器仿真程序1     %%%

%%%%          QPSK_modem_sim1.m         %%%%   
%   date: 2020-2-15    author: zjw    %%

%%%%   程序说明


%%%        仿真环境 
% 软件版本：matlab 2019a

%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%

%%%%%%%     发射机部分       %%%%%
%Preparation part
sr = 256000.0;  %符号率
ml = 2; %Number of modulation levels; BPSK--1;QPSK--2;8PSK--3;
br = sr.*ml;% bit rate
nd = 1000;  %每次循环使用的符号数目
IPOINT = 8; %符号内采样点，每个符号的采样点

%Filter initialization
%升余弦平方根滤波器
irfn = 5;   %Number of taps
alpha = 0;  %Rolloff factor
[tran_psf, den] = rcosine(1*sr, IPOINT*sr, 'fir/sqrt', alpha, irfn);
%利用rcosdesign函数设计成形滤波器
rolloff = 0; % Filter rolloff
span = 10;       % Filter span.六个符号的时长，认为是限制拖尾长度。
sps = IPOINT;        % Samples per symbol
tran_psf1 = rcosdesign(rolloff, span, sps);

%Transmitter filter coefficients
rec_psf = tran_psf1; %Receiver filter coefficients

%%% start ber calculation
nloop=100;  %Number of simulation loops
noe = 0;    %Number of error data
nod = 0;    %Number of transmitted data

ebno = 18;   %Eb/No
fig1 = figure('Name','星座图');
axis([-2 2 -2 2]);

for iii=1:nloop
    %ebno = iii/5;
    %Data generation
    data1 = randi(2,1,nd*ml)-1;%0、1序列，QPSK情况下，两个一组参与调制。
    %QPSK Modulation
    %para2*para3表示输入数据(para1)的大小;ml=2表示调制方式为QPSK
    [ich,qch] = qpskmod(data1,1,nd,ml);%这里就是将QPSK一个码元内的bit分成两路
        
    [ich1,qch1] = compoversamp(ich,qch,length(ich),IPOINT);%通过补零的方式升采样
    %成形滤波
    [ich2, qch2] = compconv(ich1, qch1, tran_psf);
    %Attenuation Calculation
    spow = sum(ich2.*ich2+qch2.*qch2)/nd;
    attn = 0.5*spow*sr/br*10.^(-ebno/10);
    attn = sqrt(attn);
    %Fading Channel
    %-----
    
    %Add White Gaussian Noise (AWGN)
    noise_iout = randn(1,length(ich2)).*attn;
    noise_qout = randn(1,length(qch2)).*attn;
    ich3 = noise_iout+ich2;
    qch3 = noise_qout+qch2;
    
    %*************   QPSK Demodulation   **************
    %匹配滤波
    [ich4, qch4] = compconv(ich3, qch3, rec_psf);
    syncpoint = 2*irfn*IPOINT+1;
    ich5 = ich4(syncpoint:IPOINT:length(ich4));
    qch5 = qch4(syncpoint:IPOINT:length(qch4));
    
    [demodata] = qpskdemod(ich5, qch5, 1, nd, ml);
    
    %************    Bit Error Rate, BER   ************
    noe2 = sum(abs(data1-demodata));
    nod2 = length(data1);
    noe = noe + noe2;
    nod = nod + nod2;
    fprintf('%d\t%e\n', iii, noe2/nod2);
    
    pause(100/1000);%暂停
end %for iii=1:nloop

ber = noe/nod;
fprintf('%d\t%d\t%d\t%e\n', ebno, noe, nod, noe/nod);

    
    
 