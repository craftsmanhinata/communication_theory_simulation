clc;clear;close all;
%(7,4)BCH��
n = 7;%�볤
k = 4;%��Ϣ�鳤��
num = 100;%BCH��Ŀ
errt = 0.01;
[genpoly,t] = bchgenpoly(n,k);%���ɶ���ʽ�;�������
msg = randi([0 1],num,k); %��Ϣÿ��һ��bch
%msg = [0 1 0 1];
Gmsg = gf(msg);%ת��Galois��
%��򵥵ı������﷨�ṹ
c1 = bchenc(Gmsg,n,k);
%c1 = bchenc(gf([0 1 0 1]),n,k);
%c2 = bchenc(gf([0 1 1 1]),n,k);
%c3 = bchenc(gf([1 1 0 1]),n,k);
%c4 = bchenc(gf([0 0 1 1]),n,k);


c2 = reshape(c1',1,num*n);
%��������
c2 = c2 + randerr(1,num*n,num*n*errt);
c2 = c2(randi([1 n]):end);%����������ʼ�������


