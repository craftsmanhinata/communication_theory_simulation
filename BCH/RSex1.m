%% ��ָ�����ɶ���ʽ
clc;clear;close all;
m = 4;%ÿ���ű�����
n = 2^m-1;%�볤  
k = 5;%��Ϣ�鳤��
msg = gf([1 2 3 4 5; 6 7 8 9 10],m);%��Ϣ���У�ת����GF(2^m)

%����
code = rsenc(msg,n,k);
%% ָ�����ɶ���ʽ
clc;clear;close all;
m = 4;%ÿ���ű�����
n = 2^m-1;%�볤  
k = 5;%��Ϣ�鳤��
msg = gf([1 2 3 4 5; 6 7 8 9 10],m);%��Ϣ���У�ת����GF(2^m)

%�������ɶ���ʽ
g = resgenpoly(n,k,19,1);
code = rsenc(msg,n,k,g);
%% �ı�У������������е�λ��
clc;clear;close all;
m = 4;%ÿ���ű�����
n = 2^m-1;%�볤  
k = 5;%��Ϣ�鳤��
msg = gf([1 2 3 4 5; 6 7 8 9 10],m);%��Ϣ���У�ת����GF(2^m)

%����
code = rsenc(msg,n,k,'beginning');

%% ��(15,13)RS����б����������
m = 4; %ÿ�����ŵı����� 
n = 2^m-l; %�볤
k = 13;%��Ϣ�鳤�� 
data = randint(4,k,2^m); %���������Ϣ���� 
msg = gf(data,m);%����Ϣ����ת����GF(2"m)

%��򵥵ı������﷨ 
cl = rsenc(msg,n,k); 
dl = rsdec(cl,n,k);
%�ı����ɶ���ʽ
c2 = rsenc(msg,n, k,rsgenpoly(n,k,19,2));
d2 = rsdec(c2, n, k, rsgenpoly(n, k, 19, 2));
%�ı䱾ԭ����ʽ 
msg2 = gf(data,m,25); 
c3 = rsenc(msg2,n,k); 
d3 = rsdec(c3,n,k);
%�ı�У������������г��ֵ�λ��
c4 = rsenc(msg,n,k,'beginning');
d4 = rsdec(c4,n,k,'beginning');
%�����������Ƿ���ȷ
chk = isequal(d1,msg) & isequal(d2,msg) & isequal(d3,msg) & isequal(d4,msg)

%% ��(7,3)RS����б����������
m = 3; %ÿ�����ŵı����� 
n = 2^m-1; %�볤
k = 3;%��Ϣ�鳤��
msg = gf([2 7 3; 4 0 6; 5 1 1],m);%��Ϣ���У�ת����GF(2^m)

%����
code = rsenc(msg,n,k);
%�������ͼ��
errors = gf([2 0 0 0 0 0 0; 3 4 0 0 0 0 0; 5  6  7  0  0  0  0 ],m);
%��Ӵ���
noisycode = code + errors;
%����
[dec,cnumerr] = rsdec(noisycode,n,k)

%% �����������
m = 3; %ÿ�����ŵı����� 
n = 2^m-1; %�볤
k = 3;%��Ϣ�鳤��
t = (n-k)/2; %��RS��ľ�������
nw = 4; %��������Ӹ���

msgw = gf(randint(nw,k,2^m),m);%������Ϣ���У���ת����GF(2^m)
%����
c = rsenc(msgw,n,k);
%����ÿ�е�t������
noise = (1+randint(nw, n, 2^m-l)).*randerr(nw,n,t); 
%���ɤ��
cnoisy = c + noise;
%����
[dc, nerrs, corrcode] = rsdec(cnoisy, n, k);
%�����������Ƿ���ȷ
chk = isequal(dc,msgw) & isequal (corrcode, c)
nerrs %��ӡ���