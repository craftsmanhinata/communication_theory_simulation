%%%      SSB���ƽ�����������1     %%%

%%%%          sim_SSB_modem_ex1.m         %%%%   
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

fs = 200;   %����Ƶ�ʣ��ɲ����������
ts = 1/fs;  %�������
fc = 50;    %�ز�Ƶ��
t0 = 0.5;
t = 0:ts:t0;    %ʱ�������ı�ʱ�䷶Χ0~t0
df0 = 0.2;  %����Ƶ�ʷֱ��ʵ�����0.2
fm = 5;

%*****  ��Ϣ�ź�m(t)��ʱ������   ******
m = cos(2*pi*fm*t);
m_hilbert = imag(hilbert(m));   %��Ϣ�ź�m(t)��ϣ�����ر任

%*****  ��һ���֣�����   ******
%�����ز��ź�c(t)��ʱ����,��Ϊsin��cos���������Ʒ�SSB���ơ����⻹���˲�����
c = cos(2*pi*fc*t);
s = sin(2*pi*fc*t);

%DSB�ѵ��ź�u(t)��ʱ����,��AM������
u = 0.5*m.*c+0.5*m_hilbert.*s;

%�����Ϣ�źź��ѵ��źŵĸ���Ҷ�任
N1 = length(m);
N2 = fs/df0;

N = 2^(nextpow2(max(N1,N2)));   %��fft�ĵ���N
df = fs/N;  %���յ�Ƶ�ʷֱ���
f = linspace(-fs/2, fs/2-df, N);    %Ƶ�����������0Ƶ�����м�

M = fftshift(fft(m,N)/fs);  %����Ϣ�źŵĸ���Ҷ�任
U = fftshift(fft(u,N)/fs);  %���ѵ��źŵĸ���Ҷ�任

%������Ϣ�źź��ѵ��źŵ�ʱ��ͼ�ͷ�����
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
%*****   ��һ���֣����� ����   *****


%*****   �ڶ����֣�������   *****
snr = 5;   %dB��ʾ�������
snr_lin = 10^(snr/10); %���������
signal_power = (sum(u.^2))/length(u);   %�����ѵ��źŵĹ���
noise_power = signal_power/snr_lin; %���������Ĺ��ʡ���˹������ֵΪ0�����Թ���ֵ��Ӧ�����ķ���
noise_std = sqrt(noise_power);  %���������ı�׼��
noise = noise_std * randn(1,length(u)); %�õ�����������
r = u+noise;    %���ն˵Ľ����źţ�����������

%���������źŵ�ʱ��ͼ�ͷ�����
figure;
subplot(2,1,1);plot(t,r);
xlabel('t/s');ylabel('r(t)');
axis([0,0.5,-1,1]);

subplot(2,1,2);
R = fftshift(fft(r,N)/fs);  %����Ϣ�źŵĸ���Ҷ�任
plot(f,abs(R));xlabel('f/Hz');ylabel('R(f)');

%*****   �ڶ����֣�������  ���� *****

%*****   �������֣���ɽ�� *****
y = r.*c;   %��һ��ͬ�ز�ͬƵͬ��������ź����

%���ֹƵ��Ϊ30Hz�ĵ�ͨ�˲�����H(f)
fL = 30;
H = zeros(1,N);
num1 = round((fs/2-fL)/df)+1;
num2 = round((fs/2+fL)/df)+1;
H(num1:num2) = ones(1,num2-num1+1);

%��y(t)���������ͨ�����
Y = fftshift(fft(y,N)/fs);  %��y(t)�ĸ���Ҷ�任
YLPF = Y.*H;   %��y(t)������ͨ�˲�����ĸ���Ҷ�任
ylpf = ifft(ifftshift(YLPF)*fs);  %��y(t)��ʱ����ʽ


%����������źŵ�ʱ��ͼ�ͷ�����
figure;
subplot(2,1,1);plot(t,real(y(1:length(t))));    %��Ϊ��ʵ�źţ��������鲿Ҳ��С
xlabel('t/s');ylabel('y(t)');
subplot(2,1,2);plot(f,abs(Y));
xlabel('f/Hz');ylabel('Y(f)');

figure;
subplot(2,1,1);plot(t,real(ylpf(1:length(t))));    %��Ϊ��ʵ�źţ��������鲿Ҳ��С
xlabel('t/s');ylabel('ylpf(t)');
subplot(2,1,2);plot(f,abs(YLPF));
xlabel('f/Hz');ylabel('YLPF(f)');