%%%         程序说明
% 仿真2ASK。
% Source ： https://blog.csdn.net/hxxjxw/article/details/82628565

%%%                       仿真环境 
% 软件版本：R2019a

%**********************   准备   *******************
clc; 
clear;
close all;

%*********************   开始仿真   *******************
i=10;%10个码元
j=5000;
t=linspace(0,5,j);%0-5之间产生5000个点行矢量，即将[0,5]分成5000份
fc=10;%载波频率
fm=i/5;%码元速率
%产生基带信号
x=(rand(1,i));%rand函数产生在0-1之间随机数，共1-10个
%figure(2)l;plot(x);
a=round(x);%随机序列，round取最接近小数的整数
%>0.5的值就为1，<0.5的值就为0
%figure(3);stem(a);%火柴梗状图
 
st=t;
for n=1:10
    if a(n)<1
        disp(j/i*(n-1))
        for m=j/i*(n-1)+1:j/i*n  %a(1)是1的话,就将0-1赋值为1
            st(m)=0;
        end
    else
        for m=j/i*(n-1)+1:j/i*n
            st(m)=1;
        end
    end
end
figure(1);
subplot(421);
plot(t,st);
 
axis([0,5,-1,2]);
title('基带信号st');
%载波
s1=cos(2*pi*fc*t);
subplot(422);
plot(s1);
title('载波信号s1');
 
%调制
e_2ask=st.*s1;%st是基带信号,s1是载波
subplot(423);
plot(t,e_2ask);
title('已调信号');
 
noise =rand(1,j);
e_2ask=e_2ask+noise;%加入噪声
subplot(424);
plot(t,e_2ask);
title('加入噪声的信号');
 
%相干解调
at=e_2ask.*cos(2*pi*fc*t);%这里用的cos必须和载波s1完全同步
%subplot(428);plot(t,at);
at=at-mean(at);%因为是单极性波形，还有直流分量，应去掉
subplot(425);
plot(t,at);
title('与载波相乘后信号');
 
[f,af] = T2F(t,at);%通过低通滤波器
[t,at] = lpf(f,af,2*fm);
subplot(426);
plot(t,at);
title('相干解调后波形');
 
%非相干解调
de_2ask1 = e_2ask - mean(e_2ask);   %去直流分量
de_2ask2 = abs(de_2ask1);   %全波整流 
[f1,af1] = T2F(t,de_2ask2);%通过低通滤波器
[t2,at2] = lpf(f1,af1,2*fm);
subplot(427);
plot(t2,at2);
title('非相干解调后波形');



%抽样判决
for m=0:i-1 %i=10   i是码元个数
    if (at(1,m*500+250)+0.5)<0.5%500是1个码元的长度，+250就是正好每次都定位到每个码元中部
        for j=m*500+1:(m+1)*500%如果判决这位码元的值<0.5,那么这个码元判为0
            at(1,j)=0;
        end
    else
        for j=m*500+1:(m+1)*500
            at(1,j)=1;%否则判为1
        end
    end
end
subplot(428);
plot(t,at);
axis([0,5,-1,2]);
title('抽样判决后波形')

%观察信号的频谱
% figure;plot(abs(fftshift(fft(fsk.*s2))))
% hold on;
% plot(abs((fft(st2))))

%*********************   自定义函数   *******************
function [f,sf]= T2F(t,st)
%利用FFT计算信号的频谱并与信号的真实频谱的抽样比较。
%脚本文件T2F.m定义了函数T2F，计算信号的傅立叶变换。
%Input is the time and the signal vectors,the length of time must greater
%than 2
%Output is the frequency and the signal spectrum
    dt = t(2)-t(1);
    T=t(end);
    df = 1/T;
    N = length(st);
    f=-N/2*df : df : N/2*df-df;
    sf = fft(st);
    sf = T/N*fftshift(sf);
end

function [t,st]=F2T(f,sf)
%脚本文件F2T.m定义了函数F2T，计算信号的反傅立叶变换。
%This function calculate the time signal using ifft function for the input
    df = f(2)-f(1);
    Fmx = ( f(end)-f(1) +df);
    dt = 1/Fmx;
    N = length(sf);
    T = dt*N;
    %t=-T/2:dt:T/2-dt;
    t = 0:dt:T-dt;  
    sff = fftshift(sf);
    st = Fmx*ifft(sf);
end


function [t,st]=lpf(f,sf,B)
%This function filter an input data using a lowpass filter
%Inputs: f: frequency samples
% sf: input data spectrum samples
% B: lowpass bandwidth with a rectangle lowpass
%Outputs: t: time samples
% st: output data time samples
    df = f(2)-f(1);
    T = 1/df;
    hf = zeros(1,length(f));%全零矩阵
    bf = [-floor( B/df ): floor( B/df )] + floor( length(f)/2 );
    hf(bf)=1;
    yf=hf.*sf;
    [t,st]=F2T(f,yf);    
    st = real(st);
end


