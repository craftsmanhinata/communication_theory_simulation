%% 没有添加任何传输错误
clc;clear;close all;
%对(15,5)BCH码进行编译码的例子
n = 15;%码长
k = 5;%信息组长度
msg = randi([0 1],1,k); %信息
Gmsg = gf(msg);%转到Galois域
%最简单的编译码语法结构
c1 = bchenc(Gmsg,n,k);
d1 = bchdec(c1,n,k);

%改变校验符号位置的BCH码编译码语法结构
c2 = bchenc(Gmsg,n,k,'beginning');
d2 = bchdec(c2 ,n,k,'beginning');

%检查编译码过程是否正确
chk = isequal(d1,msg) & isequal(d2,msg);
disp(chk);
%% 添加传输错误
clc;clear;close all;
%对(15,5)BCH码进行编译码的例子
n = 15;%码长
k = 5;%信息组长度
[gp,t] = bchgenpoly(n,k); %计算BCH码的生成多项式gp,t为该码的纠错能力。
nw = 1; %编译码处理的信息组数
msgw = gf(randi([0 1],nw,k));%随机产生nw组信息，每组长度k，转到GF域
c = bchenc(msgw,n,k);%BCH 编码
noise = randerr(nw,n,t);%产生每行t个错误的噪声
cnoisy = c + noise; %添加噪声
[dc,nerrs,corrcode] = bchdec(cnoisy,n,k); %BCH译码
%检查译码过程是否正确
chk2 = isequal(dc,msgw) & isequal(corrcode,c);
err = nerrs' %打印在bchdec译码过程中纠正了多少错误

%% (63,57)只能纠正单个错误，但是接收码子中有2个错误的译码处理过程
clc;clear;close all;
n = 63;%码长
k = 57;%信息组长度
msg = gf(randi([0 1],1,k));%生成随机信息组
%msg = gf(randint(1,k,2,9973)); %9973代表一个随机数因子
code = bchenc(msg,n,k);%编码 
%添加2个错误到码字
cnumerr2 = zeros(nchoosek(n,2),1);
nErrs = zeros(nchoosek(n,2),1);
cnumerrIdx = 1 ;
for idx1 = 1:n-1
    sprintf('idx1 for 2 errors = %d', idx1);
    for idx2 = idx1+1 : n %遍历所有的取两个位置的情况
        errors = zeros(1,n);
        errors(idx1) = 1;
        errors(idx2) = 1;
        erroredCode = code + gf(errors);%加2位错误

        [decoded2, cnumerr2(cnumerrIdx)] = bchdec(erroredCode, n, k);
        %如果bchdec认为仅纠正了一个错误，然后对译码信怠进行编码 
        %检査重新编码后的消息与有错码字之间的差别 
        if cnumerr2(cnumerrIdx) == 1
            code2 = bchenc(decoded2, n, k);
            nErrs(cnumerrIdx) = biterr(double(erroredCode.x),double(code2.x));
        end
        cnumerrIdx = cnumerrIdx + 1;
    end
end
%绘制根据译码结果重编码后得到的码字与包含2个错误的输入译码码宇之间的错误数曲线 
plot(nErrs);
title('重编码码字和输入之间的错误数');
%---------------------------------我是可爱的页面分割线-------------------------------------
%% 
clc;clear;close all;
m = 4;
n = 2^m-1;%码长  
k = 5;%信息组长度
nwords = 10;%编码的信息组数 
msg = gf(randi([0,1],nwords,k));%生成随机信息组
%计算该BCH码的纠错能力t
[genpoly, t] = bchgenpoly(n, k);

%定义一个变量t2,表示在码字中添加的错误数，这里等于码的纠错能力
t2 = t;
%编码
code = bchenc(msg,n,k);
%在每个码字中添加t2个错误
noisycode = code + randerr(nwords,n,1:t2);
%译码
[newmsg,err,ccode] = bchdec(noisycode,n,k); 
if ccode==code
    disp('All errors were corrected.'); 
end
if newmsg==msg
    disp('The message was recovered perfectly.') 
end