% clc;clear;close all;
% %(7,4)BCH��
% n = 7;%�볤
% k = 4;%��Ϣ�鳤��
% num = 100;%BCH��Ŀ
% errt = 0.01;
% [genpoly,t] = bchgenpoly(n,k);%���ɶ���ʽ�;�������
% msg = randi([0 1],num,k); %��Ϣÿ��һ��bch
% %msg = [0 1 0 1];
% Gmsg = gf(msg);%ת��Galois��
% %��򵥵ı������﷨�ṹ
% c1 = bchenc(Gmsg,n,k);
% %c1 = bchenc(gf([0 1 0 1]),n,k);
% %c2 = bchenc(gf([0 1 1 1]),n,k);
% %c3 = bchenc(gf([1 1 0 1]),n,k);
% %c4 = bchenc(gf([0 0 1 1]),n,k);


% c2 = reshape(c1',1,num*n);
% %��������
% c2 = c2 + randerr(1,num*n,num*n*errt);
% c2 = c2(randi([1 n]):end);%����������ʼ�������


N=20;%������������
save = 0;%����������
p1 = 0.8;%�������޳�����
p2 = 0.8;%�ж��볤�Ƿ���ȷ

m = 3;
for ml = 3 : 2^m%mlΪ�볤
    for start = 1:ml
        %ȡN������
        c3 = c2(start:start+N*ml-1);
        c4 = reshape(c3,ml,N);
        c5 = c4';
        save = 0;
        %���������ӵĹ���ʽ
        for n1 = 1:N
            count = 0;
            for n2 = 1:N
                ggcf = gf2vecgcd(c5(n1,:),c5(n2,:));
                if(length(ggcf)>=m)
                    count = count+1;
                end
            end
            if count/N > p1 %�жϽ�����,���޳�����
                save = save + 1;
                %������ȷ����
            end
        end
        if save/N>p2%�жϱ�����Ŀ
            ml
            start
        end       
    end%start  
end%ml







