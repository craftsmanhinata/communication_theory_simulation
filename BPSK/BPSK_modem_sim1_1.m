%%%      BPSK���ƽ�����������ܷ������1     %%%

%%%%          BPSK_modem_sim1.m         %%%%   

%   date: 2020-02-14    author: zjw    %%


%%%%   ����˵��

% ���BPSK���ƽ�����ķ��棬
% �Ƚϲ�ͬ������µ��������ܡ�
% ͨ�����ƾ����������£�
% ���Ʒ�ʽ��BPSK   ���뷽ʽ����
% �������ӣ�0.5
% �����ʽ����ɽ��  ���뷽ʽ����
% ���������Ը�˹������
% ��Ƶ�źŷ��淽ʽ

%%%        ���滷�� 
% ����汾��matlab 2019a



%*****    ����ǰ׼��   *****%
clear;
close all;
clc;
format long;

%%*********       ��������        *********%%

%%%%%%%     ϵͳ����       %%%%%   
bit_rate = 1000;
symbol_rate = 1000;
fre_sample = 16000;
symbol_sample_rate = 16;  % һ�������ڵĲ�������
fre_carrier = 4000;   %��Ƶ����

%%%%      ��Դ       %%%%%      

%%% ����ź�
% msg_source = randint(1,1000);
msg_source = [ones(1,20) zeros(1,20) randi([0,1],1,960)];  
%randi([imin,imax],m,n)
% ������־�Ե�֡ͷ��������ԡ�
% ͨ��֡ͷ�������Ƶ���У�Ϊ�˷�����ԣ����Բ���ȫ1��ȫ0��


%%%%%%     �����      %%%%%%%%      
%%%%% ������
% bchcode  % BCH���뺯��

%%%%% ������
%%% ˫���Ա任 
bipolar_msg_source = 2*msg_source - 1; %��0,1���б任Ϊ-1,1����

%%% �˲���
%rcosflt   ���������˲�
%rcos_msg_source = rcosflt(bipolar_msg_source,1000,16000);
% Roll-off factor Ĭ��Ϊ 0.5��
rolloff = 0.5;     % Rolloff factor
span = 6;           % Filter span in symbols
sps = symbol_sample_rate;            % Samples per symbol
%Generate the square-root, raised cosine filter coefficients.
raised_cosine_filter = rcosdesign(rolloff, span, sps);
%�����Ϣ���о��ǵõ��Ļ�������
%rcos_msg_source = conv(raised_cosine_filter,bipolar_msg_source);
%��ʽһ
%rcos_msg_source = rcosflt(bipolar_msg_source,1000,16000);
%��ʽ��
rcos_msg_source = upfirdn(bipolar_msg_source, raised_cosine_filter, sps);
% Ƶ��۲�
fft_rcos_msg_source = abs(fft(rcos_msg_source));

figure(1)
plot(rcos_msg_source,'-*')
title('ʱ����')
figure(2)
plot(fft_rcos_msg_source)
title('Ƶ����')


%%% �ز�����

time = 1:length(rcos_msg_source);
rcos_msg_source_carrier = rcos_msg_source.*cos(2*pi*fre_carrier.*time/fre_sample);

% Ƶ��۲�
fft_rcos_msg_source_carrier = abs(fft(rcos_msg_source_carrier));
figure(3)
plot(rcos_msg_source_carrier)
title('ʱ����')
figure(4)
plot(fft_rcos_msg_source_carrier)
title('Ƶ����')

%%%%%%       �ŵ�       %%%%%% 
% ���������
snr = -5;
%%% ��˹�������ŵ�
rcos_msg_source_carrier_noise = awgn(rcos_msg_source_carrier,snr,'measured');


%%%%%%      ���ջ�      %%%%%%%      
%%%%% �����
%%% �ز��ָ�
% ���ɱ����ز�
rcos_msg_source_noise=rcos_msg_source_carrier_noise.*cos(2*pi*fre_carrier.*time/fre_sample);

% �˲���Ƶ�����������ź�
LPF_fir128 = fir1(128,0.2);  %  ���ɵ�ͨ�˲���
rcos_msg_source_LP = filter(LPF_fir128, 1, rcos_msg_source_noise);
% ��ʱ64�������������

figure(5)
plot(rcos_msg_source_LP)
title('ʱ����')
figure(6)
plot(abs(fft(rcos_msg_source_LP)))
title('Ƶ����')



% ƥ���˲���
rcos_msg_source_MF = filter(raised_cosine_filter, 1, rcos_msg_source_LP);


figure(7)
plot(rcos_msg_source_MF,'-*')
title('ʱ����')
figure(8)
plot(abs(fft(rcos_msg_source_MF)))
title('Ƶ����')



%%% ��Ѳ�����
% ѡȡ��Ѳ����㣬һ������ȡһ��������о�
decision_site = 160; % (96+128+96)/2 = 160  �����˲����ӳ�ֵ,�ӳ�ΪN/2�������ۼ�����Ϊ����
rcos_msg_source_MF_option = rcos_msg_source_MF(decision_site: symbol_sample_rate : end);
% �漰�����˲������̺��������˲����ӳ��ۼӡ�

%%% �о�
msg_source_MF_option_sign = sign(rcos_msg_source_MF_option);

figure(9)
plot(rcos_msg_source_MF_option,'-*')
title('ʱ����')

%%%% ������
% bchdecode  % BCH����


%%%%%         ����     %%%%%%  
%%% �������ܱȶ�
[err_number, bit_err_ratio] = biterr(msg_source(1:length(rcos_msg_source_MF_option)), (msg_source_MF_option_sign + 1)/2);
err_number
bit_err_ratio

%%%��ͼ
%�������ͼ
eyediagram(rcos_msg_source,sps);
title('�������ͼ');
eyediagram(rcos_msg_source_MF,sps);
title('���ն���ͼ');

scatterplot(rcos_msg_source);
title('BPSK����ͼ')
scatterplot(rcos_msg_source_MF);
title('BPSK����ͼ')
