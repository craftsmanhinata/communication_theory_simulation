%%%         ����˵��
% ����2FSK��

%%%                       ���滷�� 
% ����汾��R2019a
clc;
clear;
close all;

%-----         ��������      --------%
%��Դ
Fc = 150;   %��Ƶ
Fs = 40;    %ϵͳ����Ƶ��
Fd = 1; %������
N = Fs/Fd;  %
df = 10;
numSymb = 25;   %���з������Ϣ�������
M = 2;  %������
SNRpBit = 60;   %�����
SNR = SNRpBit/log2(M); %60?????
seed = [12345 54321];

numPlot = 15;
x = randsrc(numSymb, 1, [0:M-1]);   %����25�������������

figure(1);
stem([0:numPlot-1], x(1:numPlot), 'bx');%��ʾ15����Ԫ����ͼ����x��ǰ15���������ѡȡ
title('�������������');
xlabel('Time');
ylabel('Amplitude');

%����
y = dmod(x,Fc,Fd,Fs,'fsk',M,df);    %���ִ�ͨ����
numModPlot =numPlot*Fs; %15*40
t = (0:numModPlot-1)./Fs;   %����ʱ��

figure(2);
plot(t,y(1:length(t)),'b-');
axis([min(t) max(t) -1.5 1.5]);
title('����֮����ź�');
xlabel('Time');
ylabel('Amplitude');

%���ѵ��ź��м����˹������
randn('state',seed(2)); %����-2��+2֮������������
y = awgn(y,SNR-10*log10(0.5)-10*log10(N), 'measured',[], 'dB');%���ѵ��ź��м����˹������
figure(3);
plot(t,y(1:length(t)),'b-');%���������ŵ���ʵ���ź�
axis([min(t) max(t) -1.5 1.5]);
title('�����˹����������ѵ��ź�');
xlabel('Time');
ylabel('Amplitude');

%��ɽ��
figure(4);
z1 = ddemod(y,Fc,Fd,Fs,'fsk',M,df);

%��������ε����MԪƵ�Ƽ��ؽ��
stem((0:numPlot-1),x(1:numPlot),'bx');
hold on;
stem((0:numPlot-1),z1(1:numPlot),'ro');
hold off;
axis([0 numPlot -0.5 1.5]);
title('��ɽ�����ź�ԭ���бȽ�');
legend('ԭ����������������','��ɽ������ź�');
xlabel('Time');
ylabel('Amplitude');

%����ɽ��
figure(6)
z2 = ddemod(y,Fc,Fd,Fs,'fsk',M,df);

%��������εķ����MԪƵ�Ƽ��ؽ��
stem((0:numPlot-1),x(1:numPlot),'bx');
hold on;
stem((0:numPlot-1),z2(1:numPlot),'ro');
hold off;
axis([0 numPlot -0.5 1.5]);
title('��ɽ�����ź�ԭ���бȽ�');
legend('ԭ����������������','��ɽ������ź�');
xlabel('Time');
ylabel('Amplitude');


figure(7);
f = fftshift(fft(x,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('����źŵ�Ƶ��');
xlabel('Ƶ�ʣ�Hz��');

figure(8);
f = fftshift(fft(y,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('�����źŵ�Ƶ��');
xlabel('Ƶ�ʣ�Hz��');

figure(9);
f = fftshift(fft(z1,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('�����źŵ�Ƶ��');
xlabel('Ƶ�ʣ�Hz��');

figure(10);
f = fftshift(fft(z2,1000));
w = linspace(-2000/2,2000/2,1000);
plot(w,abs(f));
title('�����źŵ�Ƶ��');
xlabel('Ƶ�ʣ�Hz��');














