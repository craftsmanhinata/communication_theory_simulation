% =========================================================================
% ��·���棺K = Kd * K0 * Klpf
% Kd = 1/2 * Ui * U0,���������棬Ui:�����źŷ�ֵ��U0��LLP�����ֵ
% K0 = fs/2^Bnco,VCO����(Hz/V)
% Klpf:��ͨ�˲�������
%https://blog.csdn.net/HNU_Csee_wjw/article/details/102979871
% =========================================================================
%% --- ������ʼ�� 
fs = 10e3;      % ����Ƶ��10KHz
fo = 400;       % LLP����Ƶ��400Hz
df = 35;         % ��ʼƵ��Hz
fi = fo + df;   % �ź�Ƶ��
Bnco = 32;              % Ƶ���ۼ���λ��32Bits
K0 = fs/2^Bnco;         % NCO����(Hz/V),(Ƶ�ʿ���������)
 
c1 = 2^(-1);     % ��·�˲���ϵ������FPGA��Ϊ��λ����
c2 = 2^(-9);
 
lfout(1) = 0;    % ��·�˲������
temp  = 0;       % ��·�˲����м����
 
LLP_Phase_Index = 0;
PFout = 0;
LLP_Phase_init = fo * 2^Bnco / fs;  %��ʼVCOƵ�ʿ�����
 
%% --- ����400Hz���Ҳ��ź�
L = 10000;  % ���ݳ���
N = 8;      % ����λ��
st = 0:1/fs:(L-1)/fs;
si = sin(2*pi*fi*st + pi/4);   % ����Sin�����ź�
f_si = si/max(abs(si));        % ��һ������
Q_si = round(f_si * (2^(N-1)-1)); % ��������roundȡ��������
figure;
plot(st(1:1000),Q_si(1:1000));
 
%% --- FIR��ͨ�˲������
Blpf = 8;                   % �˲���ϵ������
fc  = [300 600];            % ���ɴ�
band_amplitude = [1 0];     % ����������
dev = [0.05 0.05];          % �����Ʋ�
 
[n,Wn,beta,ftype] = kaiserord(fc,band_amplitude,dev,fs);           % ��ȡkaiser�����������˲�������n����׼��Ƶ����Ե Wn����״����beta
h_kaiser = fir1(n,Wn,ftype,kaiser(n+1,beta));           % ��ȡ�˲���ϵ��
qh = round(h_kaiser/max(abs(h_kaiser))*(2^(Blpf-1)-1)); % �˲���ϵ������
qh_max = max(abs(qh));
 
Klpf   = qh_max / max(h_kaiser);   %�����˲�������
sum_qh = sum(abs(qh));
figure;
freqz(h_kaiser,1);  %��ͨ�˲�����Ӧ
title('LPF�˲�����Ӧ');
 
K = 1/2 * 2^7 * 2^7 * K0 * Klpf;    %��·����
 
%�˷���������źų�ֵ
mult = zeros(1,L);
%����������źų�ֵ
pd = zeros(1,L);
lfout(n) = 0; 
lfout(n+1) = 0;
pd(n)=0;
 
f=zeros(1,L);
 
% wn = sqrt(K/t1);
%% --- DDS���ұ�
SinTableLength = 2^10;   % DDS��sin��ĳ���1024
SinTableAmp    = 2^7-1;  % DDS��sin��������ȣ�Ϊ8λ�з�������
t = 2*pi*(0:SinTableLength - 1)/SinTableLength;
sin_table = floor(sin(t) * SinTableAmp);
cos_table = floor(cos(t) * SinTableAmp);
%DDS��λ�ۼ���Ϊ32λ����ʵ�ʴ洢��Ϊ1024������Ҫ��������
sin_table_Index_Scale = SinTableLength / (2^Bnco);
 
%% --- �������
for i=(1+n):L
 
     DDS_Phase_Index_Table = floor(LLP_Phase_Index * sin_table_Index_Scale) + 1;
     sin_nco(i) = sin_table(DDS_Phase_Index_Table);  %�������زο��źŵ�I֮·
     cos_nco(i) = cos_table(DDS_Phase_Index_Table);  %�������زο��źŵ�Q֮·
     
     mult(i) = Q_si(i)*cos_nco(i);   % PD�˷���
     %�˳���˲����ĸ�Ƶ����
     PFout = filter(qh,1,mult(i-n:i)); %����˲����Ĺ���ԭ����ֹ����ʹ��
     len = length(PFout);
     %���������
     pd(i) = PFout(len);        
     
     % ����ʱƵ
     y=fft(cos_nco(i-n:i),L);
     [m,p]=max(abs(y));
     f(i)=p*fs/L;
     
     %��·�˲����������ݻ�·�˲������ݺ�����
     lfout(i) = lfout(i-1) + c1*pd(i) + (c2-c1)*pd(i-1);
     lfout1 = temp + c1*pd(i);
     temp  = temp + c2*pd(i);
    % �������
    LLP_Phase_Index = LLP_Phase_Index +LLP_Phase_init + lfout1;  % ��·NCO�ۻ����������زο��ź�
    
    if(LLP_Phase_Index < 0)
        LLP_Phase_Index = 0;
    end
    if(LLP_Phase_Index >= 2^Bnco)
        LLP_Phase_Index = LLP_Phase_Index - 2^Bnco;
    end
end
%% --- ��ʾ
% figure;
% y2=fft(sin_nco);
% p2=angle(y2);
% phase=p2*180/pi;
% plot(phase(1:5000));
% figure;
% plot(lfout*pi/fs/180);
 
figure;
plot(pd/fs/SinTableAmp,'b');
title('���������(ʱ��-��λ��ʾ��ͼ)');
xlabel('ʱ��(t/s)');ylabel('��λ��(rad)');
xticklabels([0:1/10:1]);
 
figure;
hold on;
plot(sin_nco(1:8000)/SinTableAmp,'-k');   % �������
hold on;
plot(Q_si(1:8000)/SinTableAmp,'-g');      % ԭʼ�����źŲ���
legend('�������', 'ԭʼ����')
title('ԭʼ�źŸ�DDS������ζԱ�');
xlabel('ʱ��(t/s)');
xticklabels([0:1/10:1]);
 
 
x=zeros(1,L);
z=fft(Q_si,L);
[a,b]=max(abs(z));
x(1:L)=b*fs/L;
 
figure;
hold on;
plot(f(1:5000),'-r');
hold on;
plot(x(1:5000),'-b');
title('ʱ��-Ƶ��ʾ��ͼ');
legend('���Ƶ��', '�ο�Ƶ��')
xlabel('ʱ��(t/s)');ylabel('Ƶ��(f/Hz)');
xticklabels([0:1/10:1]);
 
figure;
phin = 2*pi*fi*st + pi/4;
 
pvco=phin-pd/fs;
t1 = 1:1:10000;
plot(t1,phin/SinTableAmp,t1,pvco/SinTableAmp)
title('�����λ��ο���λ')
legend('�ο���λ', '�����λ')
xlabel('ʱ��(t/s)');ylabel('��λ(rad)');
xticklabels([0:1/10:1]);