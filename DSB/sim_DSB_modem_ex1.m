%%%      DSB调制解调器仿真程序1     %%%

%%%%          sim_DSB_modem_ex1.m         %%%%   
%   date: 2020-2-16    author: zjw    %%

%%%%   程序说明

%%%        仿真环境 
% 软件版本：matlab 2019a


%*****    程序前准备   *****%
clear;
close all;
clc;
format long;


%%*********       程序主体        *********%%

fs = 200;   %采样频率，由采样定理决定
ts = 1/fs;  %采样间隔
fc = 50;    %载波频率
t0 = 0.5;
t = 0:ts:t0;    %时间向量的表达，时间范围0~t0
df0 = 0.2;  %定义频率分辨率的下限0.2
fm = 5;

%*****  消息信号m(t)的时域描述   ******
m = cos(2*pi*fm*t);

%*****  第一部分：调制   ******
%正弦载波信号c(t)的时域表达
c = cos(2*pi*fc*t);

%DSB已调信号u(t)的时域表达,与AM相区别
u = m.*c;

%求出消息信号和已调信号的傅里叶变换
N1 = length(m);
N2 = fs/df0;

N = 2^(nextpow2(max(N1,N2)));   %求fft的点数N
df = fs/N;  %最终的频率分辨率
f = linspace(-fs/2, fs/2-df, N);    %频率轴的向量，0频点在中间

M = fftshift(fft(m,N)/fs);  %求消息信号的傅里叶变换
U = fftshift(fft(u,N)/fs);  %求已调信号的傅里叶变换

%画出消息信号和已调信号的时域图和幅度谱
figure;
subplot(2,2,1);plot(t,m);
xlabel('t/s');ylabel('m(t)');
axis([0,0.5,-1.1,2.1]);
subplot(2,2,3);plot(t,u);
xlabel('t/s');ylabel('u(t)');
%axis([0,0.5,-1.1,2.1]);
subplot(2,2,2);plot(f,abs(M));
xlabel('f/Hz');ylabel('M(f)');
%axis([0,0.5,-1.1,2.1]);
subplot(2,2,4);plot(f,abs(U));
xlabel('f/Hz');ylabel('U(f)');
%axis([0,0.5,-1.1,2.1]);
%*****   第一部分：调制 结束   *****


%*****   第二部分：加噪声   *****
snr = 5;   %dB表示的信噪比
snr_lin = 10^(snr/10); %线性信噪比
signal_power = (sum(u.^2))/length(u);   %计算已调信号的功率
noise_power = signal_power/snr_lin; %计算噪声的功率。高斯噪声均值为0，所以功率值对应噪声的方差
noise_std = sqrt(noise_power);  %计算噪声的标准差
noise = noise_std * randn(1,length(u)); %得到的噪声向量
r = u+noise;    %接收端的接收信号，加入了噪声

%画出接收信号的时域图和幅度谱
figure;
subplot(2,1,1);plot(t,r);
xlabel('t/s');ylabel('r(t)');
axis([0,0.5,-1,1]);

subplot(2,1,2);
R = fftshift(fft(r,N)/fs);  %求消息信号的傅里叶变换
plot(f,abs(R));xlabel('f/Hz');ylabel('R(f)');

%*****   第二部分：加噪声  结束 *****

%*****   第三部分：相干解调 *****
y = r.*c;   %与一个同载波同频同相的正弦信号相乘

%求截止频率为30Hz的低通滤波器的H(f)
fL = 30;
H = zeros(1,N);
num1 = round((fs/2-fL)/df)+1;
num2 = round((fs/2+fL)/df)+1;
H(num1:num2) = ones(1,num2-num1+1);

%求y(t)经过理想低通的输出
Y = fftshift(fft(y,N)/fs);  %求y(t)的傅里叶变换
Y = Y.*H;   %求y(t)经过低通滤波器后的傅里叶变换
y = ifft(ifftshift(Y)*fs);  %求y(t)的时域表达式


%画出最后解调信号的时域图和幅度谱
figure;
subplot(2,1,1);plot(t,real(y(1:length(t))));    %因为是实信号，即便有虚部也很小
xlabel('t/s');ylabel('y(t)');

subplot(2,1,2);plot(f,abs(Y));
xlabel('f/Hz');ylabel('Y(f)');
