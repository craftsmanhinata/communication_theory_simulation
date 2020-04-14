%% 不指定生成多项式
clc;clear;close all;
m = 4;%每符号比特数
n = 2^m-1;%码长  
k = 5;%信息组长度
msg = gf([1 2 3 4 5; 6 7 8 9 10],m);%信息序列，转换到GF(2^m)

%编码
code = rsenc(msg,n,k);
%% 指定生成多项式
clc;clear;close all;
m = 4;%每符号比特数
n = 2^m-1;%码长  
k = 5;%信息组长度
msg = gf([1 2 3 4 5; 6 7 8 9 10],m);%信息序列，转换到GF(2^m)

%计算生成多项式
g = resgenpoly(n,k,19,1);
code = rsenc(msg,n,k,g);
%% 改变校验符号在码字中的位置
clc;clear;close all;
m = 4;%每符号比特数
n = 2^m-1;%码长  
k = 5;%信息组长度
msg = gf([1 2 3 4 5; 6 7 8 9 10],m);%信息序列，转换到GF(2^m)

%编码
code = rsenc(msg,n,k,'beginning');

%% 对(15,13)RS码进行编译码的例子
m = 4; %每个符号的比特数 
n = 2^m-l; %码长
k = 13;%信息组长度 
data = randint(4,k,2^m); %随机化的信息序列 
msg = gf(data,m);%将信息序列转换到GF(2"m)

%最简单的编译码语法 
cl = rsenc(msg,n,k); 
dl = rsdec(cl,n,k);
%改变生成多项式
c2 = rsenc(msg,n, k,rsgenpoly(n,k,19,2));
d2 = rsdec(c2, n, k, rsgenpoly(n, k, 19, 2));
%改变本原多项式 
msg2 = gf(data,m,25); 
c3 = rsenc(msg2,n,k); 
d3 = rsdec(c3,n,k);
%改变校验符号在码字中出现的位置
c4 = rsenc(msg,n,k,'beginning');
d4 = rsdec(c4,n,k,'beginning');
%检查译码过程是否正确
chk = isequal(d1,msg) & isequal(d2,msg) & isequal(d3,msg) & isequal(d4,msg)

%% 对(7,3)RS码进行编译码的例子
m = 3; %每个符号的比特数 
n = 2^m-1; %码长
k = 3;%信息组长度
msg = gf([2 7 3; 4 0 6; 5 1 1],m);%信息序列，转换到GF(2^m)

%编码
code = rsenc(msg,n,k);
%定义错误图样
errors = gf([2 0 0 0 0 0 0; 3 4 0 0 0 0 0; 5  6  7  0  0  0  0 ],m);
%添加错误
noisycode = code + errors;
%译码
[dec,cnumerr] = rsdec(noisycode,n,k)

%% 引入随机噪声
m = 3; %每个符号的比特数 
n = 2^m-1; %码长
k = 3;%信息组长度
t = (n-k)/2; %该RS码的纠错能力
nw = 4; %处理的码子个数

msgw = gf(randint(nw,k,2^m),m);%生成信息序列，并转换的GF(2^m)
%编码
c = rsenc(msgw,n,k);
%定义每行的t个噪声
noise = (1+randint(nw, n, 2^m-l)).*randerr(nw,n,t); 
%添加嗓声
cnoisy = c + noise;
%泽码
[dc, nerrs, corrcode] = rsdec(cnoisy, n, k);
%检查译码过程是否正确
chk = isequal(dc,msgw) & isequal (corrcode, c)
nerrs %打印输出