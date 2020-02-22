%%%         程序说明
% 理论仿真8PSK。

%%%                       仿真环境 
% 软件版本：R2019a
clc;
clear;
close all;

%-----         程序主体      --------%
% 初始化变量
num_symbol = 100000; 
% 发送符号数
M = 8;                 % 多进制值                                                          

% 生成信号
msg = randi([0 M-1],1,num_symbol);        % 由0-7的整数值组成的均匀随机数

% 8PSK调制
msgmod = pskmod(msg,M,pi/M);% pi/M为PSK信号的初相

sig_pow = norm(msgmod).^2/num_symbol;     % 计算符号的平均功率

% 设置信噪比的范围
EsN0 = 3:10;      % dB值                                      

snr = 10.^((EsN0+log2(M))/10) ;      
% 将dB值转化成线性值


for index = 1:length(EsN0)

    % 根据符号功率求出噪声功率
    sigma = sqrt(sig_pow/(2*snr(index)));         

    % 加入高斯加性白噪声
    receiver_signal = msgmod + sigma*(randn(1,length(msgmod))+1i*randn(1,length(msgmod)));

     % 8PSK解调 
     dec_msg = pskdemod(receiver_signal,M,pi/M);  

     % 计算误码率                            
     [err_bit,ber(index)] = biterr(msg,dec_msg);       

     % 误符号率不能用biterr计算，用symerr计算。
end



% 计算理论误符号率
ber_theroy_snr = berawgn(EsN0-log2(M),'psk',M,'nondiff');  

% 针对比特信噪比     


% 画误码率曲线
figure(1)
semilogy(EsN0,ber,'-*',EsN0,ber_theroy_snr,'-o')
legend('误符号率仿真结果','理论值')

grid on
title('8PSK误码性能曲线 无格雷编码')
scatterplot(receiver_signal)
title('EsN0 = 10dB')