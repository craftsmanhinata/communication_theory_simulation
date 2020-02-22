%%%         ����˵��
% ���۷���8PSK��

%%%                       ���滷�� 
% ����汾��R2019a
clc;
clear;
close all;

%-----         ��������      --------%
% ��ʼ������
num_symbol = 100000; 
% ���ͷ�����
M = 8;                 % �����ֵ                                                          

% �����ź�
msg = randi([0 M-1],1,num_symbol);        % ��0-7������ֵ��ɵľ��������

% 8PSK����
msgmod = pskmod(msg,M,pi/M);% pi/MΪPSK�źŵĳ���

sig_pow = norm(msgmod).^2/num_symbol;     % ������ŵ�ƽ������

% ��������ȵķ�Χ
EsN0 = 3:10;      % dBֵ                                      

snr = 10.^((EsN0+log2(M))/10) ;      
% ��dBֵת��������ֵ


for index = 1:length(EsN0)

    % ���ݷ��Ź��������������
    sigma = sqrt(sig_pow/(2*snr(index)));         

    % �����˹���԰�����
    receiver_signal = msgmod + sigma*(randn(1,length(msgmod))+1i*randn(1,length(msgmod)));

     % 8PSK��� 
     dec_msg = pskdemod(receiver_signal,M,pi/M);  

     % ����������                            
     [err_bit,ber(index)] = biterr(msg,dec_msg);       

     % ������ʲ�����biterr���㣬��symerr���㡣
end



% ���������������
ber_theroy_snr = berawgn(EsN0-log2(M),'psk',M,'nondiff');  

% ��Ա��������     


% ������������
figure(1)
semilogy(EsN0,ber,'-*',EsN0,ber_theroy_snr,'-o')
legend('������ʷ�����','����ֵ')

grid on
title('8PSK������������ �޸��ױ���')
scatterplot(receiver_signal)
title('EsN0 = 10dB')