%%%      8PSK������ɽ�������ļ�    %%%
%%%%          8PSK_modem_sim2.m         %%%%   

%   date: 2020-02-15    author: zjw    %%


%%%%   ����˵��
%������ʵ��MATLAB�����ļ��и�����8PSK��ʹ�÷ŷ�
%

%%%        ���滷�� 
% ����汾��matlab 2019a

%*****    ����ǰ׼��   *****%
clear;
close all;
clc;
format long;

%%*********       ��������        *********%%

%%�����
sn =1000;   %��Ԫ����
ml = 3; %ÿ����Ԫ��bit����3����8PSK

%����
%���ø�����Golay Codes
%000---0*pi/4; 001---1*pi/4; 011---2*pi/4; 010---3*pi/4;
%110---4*pi/4; 111---5*pi/4; 101---6*pi/4; 100---7*pi/4;

nd = sn*ml;%3000���ܵ�bit��
%Origin_code = randi(2,1,nd)-1;
Origin_code = randi([0,1],1,nd);%���ɴ�����bit������3000bit
inf_phase_origin = 0;%���ࣿ
L = length(Origin_code)/3;  %��Ԫ����������sn
inf_phase_out = zeros(1,L); %�������λ���ܹ���sn����

%����ÿ3��bit��ȷ��1���������λ�����ø�����
for i = 1:L
    len = (i-1)*3;%Origin_code�ĵ�len����ʼȡml��bit
    if (Origin_code(len+1)==0)&&(Origin_code(len+2)==0)&&(Origin_code(len+3)==0)
        inf_phase_out(i) = inf_phase_origin+0*pi/4;
    elseif (Origin_code(len+1)==0)&&(Origin_code(len+2)==0)&&(Origin_code(len+3)==1)
        inf_phase_out(i) = inf_phase_origin+1*pi/4;
    elseif (Origin_code(len+1)==0)&&(Origin_code(len+2)==1)&&(Origin_code(len+3)==1)
        inf_phase_out(i) = inf_phase_origin+2*pi/4;
    elseif (Origin_code(len+1)==0)&&(Origin_code(len+2)==1)&&(Origin_code(len+3)==0)
        inf_phase_out(i) = inf_phase_origin+3*pi/4;
    elseif (Origin_code(len+1)==1)&&(Origin_code(len+2)==1)&&(Origin_code(len+3)==0)
        inf_phase_out(i) = inf_phase_origin+4*pi/4;
    elseif (Origin_code(len+1)==1)&&(Origin_code(len+2)==1)&&(Origin_code(len+3)==1)
        inf_phase_out(i) = inf_phase_origin+5*pi/4;
    elseif (Origin_code(len+1)==1)&&(Origin_code(len+2)==0)&&(Origin_code(len+3)==1)
        inf_phase_out(i) = inf_phase_origin+6*pi/4;
    elseif (Origin_code(len+1)==1)&&(Origin_code(len+2)==0)&&(Origin_code(len+3)==0)
        inf_phase_out(i) = inf_phase_origin+7*pi/4;
    end
    inf_phase_origin = inf_phase_out(i);%���³��࣬ÿȷ��һ����Ԫ����λ�󶼽��и���
end

%�����I��Q��·��ͨ������·��ֵ����ȷ��һ���ź���λ��
Transmit_code_I = cos(inf_phase_out);
Transmit_code_Q = sin(inf_phase_out);


Freq_Sample = 1000;
fcarrier = 100; %����Ƶƫ

%������DSP�����һЩ֪ʶ��Ҫ��˳��
%Freq_Sample�ǲ����ʣ�fcarrier���ز�Ƶ�ʡ�����exp����Ƶ���ƶ���ʱ����Ҫ����DFT��Ƶ�Ķ����


ophase = 0*pi;%�ز�����
Signal_Source = Transmit_code_I + 1i*Transmit_code_Q;
Simulation_Length = length(Transmit_code_I);%���Ƿ�����Ŀsn
%Carrier = exp(1i*(fcarrier/Freq_Sample*(1:Simulation_Length)+ophase));
Carrier = exp(1i*2*pi*(fcarrier/Freq_Sample*(1:Simulation_Length)+ophase));
%dft���������壬Ƶ��ֵ�����������
Signal_Channel=Signal_Source.*Carrier;%��Ƶ�������ź�

%���ջ�����,ʡ���˼������Ĺ���
%����һЩ׼����
Simulation_Length = length(Signal_Channel);%���Ƿ�����Ŀsn
Signal_PLL = zeros(Simulation_Length, 1);
NCO_Phase = zeros(Simulation_Length,1);

Discriminator_Out = ones(Simulation_Length,1);
Freq_Control = zeros(Simulation_Length,1);
PLL_Phase_Part = zeros(Simulation_Length,1);
PLL_Freq_Part = zeros(Simulation_Length,1);

%��·����
Bd = 500;   %��·��������
damp = 0.707;   %����ϵ��
td = 1/Freq_Sample; %��ػ���ʱ��
Kd = 1; %��·����
Wd = 2*Bd/(damp+1/(4*damp));    %��Ȼ��Ƶ��
C1 = 8*damp*Wd*td/(Kd*(4+4*damp*Wd*td+(Wd*td)^2)); %��·�˲�����ϵ��
C2 = 4*(Wd*td)^2/(Kd*(4+4*damp*Wd*td+(Wd*td)^2)); 

%���໷
for i = 2:Simulation_Length
    a = Signal_Channel(i);%��ԭʼ�ź�ƽ�����൱����λ����2������QPSK�ļ��෽��
    b = a^2;
    Signal_PLL(i) = b*exp(-1i*(2*NCO_Phase(i-1)));
    Signal_PLLdemo(i) = a*exp(-1i*NCO_Phase(i-1));  %����ź�
    I_PLL1 = real(Signal_PLL(i));
    Q_PLL1 = imag(Signal_PLL(i));
    I_PLL(i) = I_PLL1;
    Q_PLL(i) = Q_PLL1;
    I_PLLdemo(i) = real(Signal_PLLdemo(i));
    Q_PLLdemo(i) = imag(Signal_PLLdemo(i));
    
    %��·������
    Discriminator = (sign(I_PLL(i))*Q_PLL(i)-sign(Q_PLL(i))*I_PLL(i))/(sqrt(2)*sqrt(I_PLL(i)^2+Q_PLL(i)^2));
    Discriminator_Out(i) = Discriminator;
    %��·�˲�
    PLL_Phase_Part(i) = Discriminator_Out(i)*C1;
    Freq_Control(i) = PLL_Phase_Part(i) + PLL_Freq_Part(i-1);
    PLL_Freq_Part(i) = Discriminator_Out(i)*C2+PLL_Freq_Part(i-1);
    NCO_Phase(i) = NCO_Phase(i-1) + Freq_Control(i);    
end

rec_phase_origin = 0;

for i=1:length(I_PLLdemo)
    rec_phase = atan2(Q_PLLdemo(i), I_PLLdemo(i))/pi;
    if rec_phase<-0.01
        rec_phase = rec_phase+2;
    end
    differ_phase(i) = rec_phase-rec_phase_origin;
    if differ_phase(i)<-0.01
        differ_phase(i) = differ_phase(i)+2;
    end
    rec_phase_origin = rec_phase;
    
    if (abs(differ_phase(i)-0/4)<=0.125)
        Receive_code((i-1)*3+1)=0;
        Receive_code((i-1)*3+2)=0;
        Receive_code((i-1)*3+3)=0;
    elseif (abs(differ_phase(i)-1/4)<=0.125)
        Receive_code((i-1)*3+1)=0;
        Receive_code((i-1)*3+2)=0;
        Receive_code((i-1)*3+3)=1;
    elseif (abs(differ_phase(i)-2/4)<=0.125)
        Receive_code((i-1)*3+1)=0;
        Receive_code((i-1)*3+2)=1;
        Receive_code((i-1)*3+3)=1;
    elseif (abs(differ_phase(i)-3/4)<=0.125)
        Receive_code((i-1)*3+1)=0;
        Receive_code((i-1)*3+2)=1;
        Receive_code((i-1)*3+3)=0;
    elseif (abs(differ_phase(i)-4/4)<=0.125)
        Receive_code((i-1)*3+1)=1;
        Receive_code((i-1)*3+2)=1;
        Receive_code((i-1)*3+3)=0;
    elseif (abs(differ_phase(i)-5/4)<=0.125)
        Receive_code((i-1)*3+1)=1;
        Receive_code((i-1)*3+2)=1;
        Receive_code((i-1)*3+3)=1;
    elseif (abs(differ_phase(i)-6/4)<=0.125)
        Receive_code((i-1)*3+1)=1;
        Receive_code((i-1)*3+2)=0;
        Receive_code((i-1)*3+3)=1;
    elseif (abs(differ_phase(i)-7/4)<=0.125)
        Receive_code((i-1)*3+1)=1;
        Receive_code((i-1)*3+2)=0;
        Receive_code((i-1)*3+3)=0;
    end
end




%�漰�����໷����̫���



