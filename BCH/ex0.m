clc;clear;close all;
%(7,4)BCH码
n = 7;%码长
k = 4;%信息组长度
num = 100;%BCH数目
errt = 0.01;
[genpoly,t] = bchgenpoly(n,k);%生成多项式和纠错能力
msg = randi([0 1],num,k); %信息每行一个bch
%msg = [0 1 0 1];
Gmsg = gf(msg);%转到Galois域
%最简单的编译码语法结构
c1 = bchenc(Gmsg,n,k);
%c1 = bchenc(gf([0 1 0 1]),n,k);
%c2 = bchenc(gf([0 1 1 1]),n,k);
%c3 = bchenc(gf([1 1 0 1]),n,k);
%c4 = bchenc(gf([0 0 1 1]),n,k);


c2 = reshape(c1',1,num*n);
%加入噪声
c2 = c2 + randerr(1,num*n,num*n*errt);
c2 = c2(randi([1 n]):end);%接收码子起始比特随机


