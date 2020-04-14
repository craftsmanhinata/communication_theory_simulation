%% û������κδ������
clc;clear;close all;
%��(15,5)BCH����б����������
n = 15;%�볤
k = 5;%��Ϣ�鳤��
msg = randi([0 1],1,k); %��Ϣ
Gmsg = gf(msg);%ת��Galois��
%��򵥵ı������﷨�ṹ
c1 = bchenc(Gmsg,n,k);
d1 = bchdec(c1,n,k);

%�ı�У�����λ�õ�BCH��������﷨�ṹ
c2 = bchenc(Gmsg,n,k,'beginning');
d2 = bchdec(c2 ,n,k,'beginning');

%������������Ƿ���ȷ
chk = isequal(d1,msg) & isequal(d2,msg);
disp(chk);
%% ��Ӵ������
clc;clear;close all;
%��(15,5)BCH����б����������
n = 15;%�볤
k = 5;%��Ϣ�鳤��
[gp,t] = bchgenpoly(n,k); %����BCH������ɶ���ʽgp,tΪ����ľ���������
nw = 1; %�����봦�����Ϣ����
msgw = gf(randi([0 1],nw,k));%�������nw����Ϣ��ÿ�鳤��k��ת��GF��
c = bchenc(msgw,n,k);%BCH ����
noise = randerr(nw,n,t);%����ÿ��t�����������
cnoisy = c + noise; %�������
[dc,nerrs,corrcode] = bchdec(cnoisy,n,k); %BCH����
%�����������Ƿ���ȷ
chk2 = isequal(dc,msgw) & isequal(corrcode,c);
err = nerrs' %��ӡ��bchdec��������о����˶��ٴ���

%% (63,57)ֻ�ܾ����������󣬵��ǽ�����������2����������봦�����
clc;clear;close all;
n = 63;%�볤
k = 57;%��Ϣ�鳤��
msg = gf(randi([0 1],1,k));%���������Ϣ��
%msg = gf(randint(1,k,2,9973)); %9973����һ�����������
code = bchenc(msg,n,k);%���� 
%���2����������
cnumerr2 = zeros(nchoosek(n,2),1);
nErrs = zeros(nchoosek(n,2),1);
cnumerrIdx = 1 ;
for idx1 = 1:n-1
    sprintf('idx1 for 2 errors = %d', idx1);
    for idx2 = idx1+1 : n %�������е�ȡ����λ�õ����
        errors = zeros(1,n);
        errors(idx1) = 1;
        errors(idx2) = 1;
        erroredCode = code + gf(errors);%��2λ����

        [decoded2, cnumerr2(cnumerrIdx)] = bchdec(erroredCode, n, k);
        %���bchdec��Ϊ��������һ������Ȼ��������ŵ����б��� 
        %������±�������Ϣ���д�����֮��Ĳ�� 
        if cnumerr2(cnumerrIdx) == 1
            code2 = bchenc(decoded2, n, k);
            nErrs(cnumerrIdx) = biterr(double(erroredCode.x),double(code2.x));
        end
        cnumerrIdx = cnumerrIdx + 1;
    end
end
%���Ƹ����������ر����õ������������2�������������������֮��Ĵ��������� 
plot(nErrs);
title('�ر������ֺ�����֮��Ĵ�����');
%---------------------------------���ǿɰ���ҳ��ָ���-------------------------------------
%% 
clc;clear;close all;
m = 4;
n = 2^m-1;%�볤  
k = 5;%��Ϣ�鳤��
nwords = 10;%�������Ϣ���� 
msg = gf(randi([0,1],nwords,k));%���������Ϣ��
%�����BCH��ľ�������t
[genpoly, t] = bchgenpoly(n, k);

%����һ������t2,��ʾ����������ӵĴ����������������ľ�������
t2 = t;
%����
code = bchenc(msg,n,k);
%��ÿ�����������t2������
noisycode = code + randerr(nwords,n,1:t2);
%����
[newmsg,err,ccode] = bchdec(noisycode,n,k); 
if ccode==code
    disp('All errors were corrected.'); 
end
if newmsg==msg
    disp('The message was recovered perfectly.') 
end