%%%      PCM仿真程序1     %%%

%%%%          sim_PCM_modem_ex1.m         %%%%   
%   date: 2020-2-16    author: zjw %%

%%%%   程序说明

%%%        仿真环境 
% 软件版本：matlab 2019a


%*****    程序前准备   *****%
clear;
close all;
clc;
format long;


%%*********       程序主体        *********%%

t = 0:0.01:10;
x = sin(t);
v = max(x);
xx = x/v;   %normalize

sxx = floor(xx*4096);
y = pcm_encode(sxx);
yy = pcm_decode(y,v);

drawnow;
figure(1);
set(1,'Position',[10,350,600,200]);%设定窗口位置和大小
plot(t,x);
title('sample sequence');
figure(2);
set(2,'Position',[10,50,600,200]);%设定窗口位置和大小
plot(t,yy);
title('pcm decode sequence');


%PCM编码子程序
function [out] = pcm_encode(x)  %x encode to pcm code
    
    n = length(x);  % -4096<x<4096
    for i = 1:n
        if x(i)>0
            out(i,1) = 1;
        else
            out(i,1) = 0;
        end
        
        if abs(x(i))>=0 && abs(x(i))<32
            out(i,2) = 0;
            out(i,3) = 0;
            out(i,4) = 0;
            step = 2;
            st = 0;
        elseif abs(x(i))>=32 && abs(x(i))<64
            out(i,2) = 0;
            out(i,3) = 0;
            out(i,4) = 1;
            step = 2;
            st = 32;
        elseif abs(x(i))>=64 && abs(x(i))<128
            out(i,2) = 0;
            out(i,3) = 1;
            out(i,4) = 0;
            step = 4;
            st = 64;
        elseif abs(x(i))>=128 && abs(x(i))<256
            out(i,2) = 0;
            out(i,3) = 1;
            out(i,4) = 1;
            step = 8;
            st = 128;
        elseif abs(x(i))>=256 && abs(x(i))<512
            out(i,2) = 1;
            out(i,3) = 0;
            out(i,4) = 0;
            step = 16;
            st = 256;
        elseif abs(x(i))>=512 && abs(x(i))<1024
            out(i,2) = 1;
            out(i,3) = 0;
            out(i,4) = 1;
            step = 32;
            st = 512;
        elseif abs(x(i))>=1024 && abs(x(i))<2048
            out(i,2) = 1;
            out(i,3) = 1;
            out(i,4) = 0;
            step = 64;
            st = 1024;
        elseif abs(x(i))>=2048 && abs(x(i))<4096
            out(i,2) = 1;
            out(i,3) = 1;
            out(i,4) = 1;
            step = 128;
            st = 2048;
        end
        
        if abs(x(i))==4096
            out(i,2:8) = [1 1 1 1 1 1 1];
        else
            tmp = floor((abs(x(i))-st)/step);
            t = dec2bin(tmp,4)-48;%函数dec2bin输出的是ASCII字符串，48对应0
            out(i,5:8) = t(1:4);
        end
    end
    out = reshape(out', 1, 8*n);
end
    
%PCM解码子程序
function [out] = pcm_decode(in, v)
    %decode the input pcm code
    %in : input the pcm code 8 bits sample
    %v  : quantized level
    n = length(in);
    in = reshape(in', 8, n/8)';
    slot(1) = 0;
    slot(2) = 32;
    slot(3) = 64;
    slot(4) = 128;
    slot(5) = 256;
    slot(6) = 512;
    slot(7) = 1024;
    slot(8) = 2048;

    step(1) = 2;
    step(2) = 2;
    step(3) = 4;
    step(4) = 8;
    step(5) = 16;
    step(6) = 32;
    step(7) = 64;
    step(8) = 128;
    
    for i = 1:n/8
        ss = 2*in(i,1)-1;
        tmp = in(i,2)*4 + in(i,3)*2 + in(i,4)+ 1;
        st = slot(tmp);
        dt = (in(i,5)*8+in(i,6)*4+in(i,7)*2+in(i,8))*step(tmp) + 0.5*step(tmp);
        out(i) = ss*(st+dt)/4096*v;
    end
end

