%%%         ����˵��
% ����2ASK��

%%%                       ���滷�� 
% ����汾��R2019a
clc;
clear;
close all;

%-----         ��������      --------%
%��Դ
a = randi([0,1], 1, 15);
t = 0:0.001:0.999;
m = a(ceil(15*t+0.01));

subplot(5,1,1);
plot(t,m);
axis([0 1.2 -0.2 1.2]);
title('��Դ');

%�ز�
f = 150;
carry = cos(2*pi*f*t);
%2ASK
st = m.*carry;
subplot(5,1,2);
plot(t, st);
axis([0 1.2 -1.2 1.2]);
title('2ASK�ź�');

%�Ӹ�˹�ź�
nst = awgn(st, 20);

%���
nst = nst.*carry;
subplot(5,1,3);
plot(t, nst);
axis([0 1.2 -0.2 1.2]);
title('��������ز�����ź�');

%��Ƶ�ͨ�˲���
wp = 2*pi*2*f*0.5;
ws = 2*pi*2*f*0.9;
Rp = 2;
As = 45;
[N,wc] = buttord(wp, ws, Rp, As, 's');
[B,A] = butter(N, wc, 's'); %��ͨ�˲�
h = tf(B,A);    %ת����Ϊ���亯��
dst = lsim(h,nst,t);
subplot(5,1,4);
plot(t,dst);
axis([0 1.2 -0.2 1.2]);
title('������ͨ�˲�������ź�');


%�о���
k = 0.25;
pdst = 1*(dst>0.25);
% ppdst = lsim(h,pdst,t);
% pppdst = 1*(ppdst>0.5);
subplot(5,1,5);
plot(t,pdst);
axis([0 1.2 -0.2 1.2]);
title('���������о�����ź�');

%Ƶ�׹۲� �����ź�Ƶ��
T = t(end);
df = 1/T;
N = length(st);
f = (-N/2:N/2-1)*df;
sf = fftshift(abs(fft(st)));
figure(2);
subplot(4,1,1);
plot(f,sf);
title('�����źŵ�Ƶ��')

%��ԴƵ��
mf = fftshift(abs(fft(m)));
subplot(4,1,2);
plot(f, mf);
title('��ԴƵ��');
%��������ز����Ƶ��
mmf = fftshift(abs(fft(nst)));
subplot(4,1,3);
plot(f,mmf);
title('��������ز����Ƶ��');
%������ͨ�˲������Ƶ��
dmf = fftshift(abs(fft(pdst)));
subplot(4,1,4);
plot(f,dmf);
title('������ͨ�˲����Ƶ��');

