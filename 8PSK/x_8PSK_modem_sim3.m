%%%      8PSK基带相干解调仿真文件    %%%
%%%%          8PSK_modem_sim2.m         %%%%   

%   date: 2020-02-15    author: zjw    %%


%%%%   程序说明
%本程序实验MATLAB帮助文件中给出的8PSK的使用放法
%

%%%        仿真环境 
% 软件版本：matlab 2019a

%*****    程序前准备   *****%
clear;
close all;
clc;
format long;

%%*********       程序主体        *********%%

%%发射机
sn =1000;   %码元个数
ml = 3; %每个码元的bit数，3代表8PSK

%编码
%采用格雷码Golay Codes
%000---0*pi/4; 001---1*pi/4; 011---2*pi/4; 010---3*pi/4;
%110---4*pi/4; 111---5*pi/4; 101---6*pi/4; 100---7*pi/4;

nd = sn*ml;%3000，总的bit数
%Origin_code = randi(2,1,nd)-1;
Origin_code = randi([0,1],1,nd);%生成待传输bit流，共3000bit
inf_phase_origin = 0;%初相？
L = length(Origin_code)/3;  %码元个数，就是sn
inf_phase_out = zeros(1,L); %输出的相位，总共有sn个。

%根据每3个bit来确定1个输出的相位，采用格雷码
for i = 1:L
    len = (i-1)*3;%Origin_code的第len个开始取ml个bit
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
    inf_phase_origin = inf_phase_out(i);%更新初相，每确定一个码元的相位后都进行更新
end

%这里分I、Q两路，通过这两路的值就能确定一个信号相位。
Transmit_code_I = cos(inf_phase_out);
Transmit_code_Q = sin(inf_phase_out);


Freq_Sample = 1000;
fcarrier = 100; %采样频偏

%这里是DSP里面的一些知识，要理顺了
%Freq_Sample是采样率，fcarrier是载波频率。利用exp进行频率移动的时候，是要满足DFT移频的定义的


ophase = 0*pi;%载波初相
Signal_Source = Transmit_code_I + 1i*Transmit_code_Q;
Simulation_Length = length(Transmit_code_I);%还是符号数目sn
%Carrier = exp(1i*(fcarrier/Freq_Sample*(1:Simulation_Length)+ophase));
Carrier = exp(1i*2*pi*(fcarrier/Freq_Sample*(1:Simulation_Length)+ophase));
%dft点数有意义，频率值后面才有意义
Signal_Channel=Signal_Source.*Carrier;%移频，发送信号

%接收机部分,省略了加噪声的过程
%这是一些准备。
Simulation_Length = length(Signal_Channel);%还是符号数目sn
Signal_PLL = zeros(Simulation_Length, 1);
NCO_Phase = zeros(Simulation_Length,1);

Discriminator_Out = ones(Simulation_Length,1);
Freq_Control = zeros(Simulation_Length,1);
PLL_Phase_Part = zeros(Simulation_Length,1);
PLL_Freq_Part = zeros(Simulation_Length,1);

%环路处理
Bd = 500;   %环路噪声带宽
damp = 0.707;   %阻尼系数
td = 1/Freq_Sample; %相关积分时间
Kd = 1; %环路增益
Wd = 2*Bd/(damp+1/(4*damp));    %自然角频率
C1 = 8*damp*Wd*td/(Kd*(4+4*damp*Wd*td+(Wd*td)^2)); %环路滤波器的系数
C2 = 4*(Wd*td)^2/(Kd*(4+4*damp*Wd*td+(Wd*td)^2)); 

%锁相环
for i = 2:Simulation_Length
    a = Signal_Channel(i);%将原始信号平方，相当于相位乘以2，采用QPSK的鉴相方法
    b = a^2;
    Signal_PLL(i) = b*exp(-1i*(2*NCO_Phase(i-1)));
    Signal_PLLdemo(i) = a*exp(-1i*NCO_Phase(i-1));  %解调信号
    I_PLL1 = real(Signal_PLL(i));
    Q_PLL1 = imag(Signal_PLL(i));
    I_PLL(i) = I_PLL1;
    Q_PLL(i) = Q_PLL1;
    I_PLLdemo(i) = real(Signal_PLLdemo(i));
    Q_PLLdemo(i) = imag(Signal_PLLdemo(i));
    
    %环路鉴相器
    Discriminator = (sign(I_PLL(i))*Q_PLL(i)-sign(Q_PLL(i))*I_PLL(i))/(sqrt(2)*sqrt(I_PLL(i)^2+Q_PLL(i)^2));
    Discriminator_Out(i) = Discriminator;
    %环路滤波
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




%涉及到锁相环，不太理解



