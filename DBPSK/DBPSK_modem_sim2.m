%%%      DBPSK调制解调器误码性能仿真程序1     %%%

%%%%          DBPSK_modem_sim1.m         %%%%   

%   date: 2020-02-14    author: zjw    %%



%%%%   程序说明


%%%        仿真环境 
% 软件版本：matlab 2019a



%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%

%%%%%%%     系统参数       %%%%%   
bit_rate = 1000;
symbol_rate = 1000;
fre_sample = 16000;
symbol_sample_rate = 16;  % 一个符号内的采样倍数
fre_carrier = 4000;   %载频

%%%%      信源       %%%%%      

%%% 随机信号
% msg_source = randint(1,1000);
msg_source =  randi([0,1],1,960);
frame_head = [ones(1,20) zeros(1,20)];
%randi([imin,imax],m,n)
% 给出标志性的帧头，方便调试。
% 通常帧头会采用扩频序列，为了方便调试，可以采用全1和全0。


%%%%%%     发射机      %%%%%%%%      
%%%%% 编码器
% bchcode  % BCH编码函数
%差分编码方式二
msg_source_diffcode = ones(1,960);
if msg_source(1) == 1
    msg_source_diffcode(1) = 1;
end
for i = 2:length(msg_source)
    msg_source_diffcode(i) = msg_source_diffcode(i-1)*(2*msg_source(i)-1);
end
%%%%组帧
frame_msg = [2*frame_head-1 msg_source_diffcode 1];




%%%%% 调制器
%%% 双极性变换 
bipolar_msg_source = frame_msg; %将0,1序列变换为-1,1序列

%%% 滤波器
%rcosflt   滚降成型滤波
%rcos_msg_source = rcosflt(bipolar_msg_source,1000,16000);
% Roll-off factor 默认为 0.5。
rolloff = 0.5;     % Rolloff factor
span = 6;           % Filter span in symbols
sps = symbol_sample_rate;            % Samples per symbol
%Generate the square-root, raised cosine filter coefficients.
raised_cosine_filter = rcosdesign(rolloff, span, sps);
%卷积信息序列就是得到的基带码型
%rcos_msg_source = conv(raised_cosine_filter,bipolar_msg_source);
%方式一
%rcos_msg_source = rcosflt(bipolar_msg_source,1000,16000);
%方式二
rcos_msg_source = upfirdn(bipolar_msg_source, raised_cosine_filter, sps);
% 频域观察
fft_rcos_msg_source = abs(fft(rcos_msg_source));

figure(1)
plot(rcos_msg_source,'-*')
title('时域波形')
figure(2)
plot(fft_rcos_msg_source)
title('频域波形')


%%% 载波发送

time = 1:length(rcos_msg_source);
rcos_msg_source_carrier = rcos_msg_source.*cos(2*pi*fre_carrier.*time/fre_sample);

% 频域观察
fft_rcos_msg_source_carrier = abs(fft(rcos_msg_source_carrier));
figure(3)
plot(rcos_msg_source_carrier)
title('时域波形')
figure(4)
plot(fft_rcos_msg_source_carrier)
title('频域波形')

%%%%%%       信道       %%%%%% 
% 设置信噪比
snr = 3;
%%% 高斯白噪声信道
rcos_msg_source_carrier_noise = awgn(rcos_msg_source_carrier,snr,'measured');


%%%%%%      接收机      %%%%%%%    
%%%相干解调结合差分译码模式
%%%%% 解调器
%%% 载波恢复
% 生成本地载波
rcos_msg_source_noise=rcos_msg_source_carrier_noise.*cos(2*pi*fre_carrier.*time/fre_sample);

% 滤波高频，保留基带信号
LPF_fir128 = fir1(128,0.2);  %  生成低通滤波器
rcos_msg_source_LP = filter(LPF_fir128, 1, rcos_msg_source_noise);
% 延时64个采样点输出。

figure(5)
plot(rcos_msg_source_LP)
title('时域波形')
figure(6)
plot(abs(fft(rcos_msg_source_LP)))
title('频域波形')



% 匹配滤波器
rcos_msg_source_MF = filter(raised_cosine_filter, 1, rcos_msg_source_LP);


figure(7)
plot(rcos_msg_source_MF,'-*')
title('时域波形')
figure(8)
plot(abs(fft(rcos_msg_source_MF)))
title('频域波形')



%%% 最佳采样点
% 选取最佳采样点，一个符号取一个点进行判决
decision_site = 160; % (96+128+96)/2 = 160  三个滤波器延迟值,延迟为N/2，有理论计算作为依据
rcos_msg_source_MF_option = rcos_msg_source_MF(decision_site: symbol_sample_rate : end);
% 涉及三个滤波器，固含有三个滤波器延迟累加。


figure(9)
plot(rcos_msg_source_MF_option,'-*')
title('时域波形')

%%%% 解码器
% bchdecode  % BCH译码

%%%差分解调,用延迟乘的差分解调方式
rcos_msg_source_diff_MF_option = rcos_msg_source_MF_option(1:end-1).*rcos_msg_source_MF_option(2:end);
%%%判决
msg_source_MF_option_sign = sign(rcos_msg_source_MF_option);
msg_source_diff_MF_option_sign = sign(rcos_msg_source_diff_MF_option);
%%%解码器
frame_msg_demod = msg_source_diff_MF_option_sign(41:40+900);

%%%%%         信宿     %%%%%%  
%%% 误码性能比对
[err_number, bit_err_ratio] = biterr(msg_source(2:length(frame_msg_demod)+1), (frame_msg_demod + 1)/2);
err_number
bit_err_ratio

%%%眼图
%发射端眼图
eyediagram(rcos_msg_source,sps);
title('发射端眼图');
eyediagram(rcos_msg_source_MF,sps);
title('接收端眼图');

scatterplot(rcos_msg_source);
title('BPSK星座图')
scatterplot(rcos_msg_source_MF);
title('BPSK星座图')
