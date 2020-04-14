% clc;clear;close all;
% %(7,4)BCH码
% n = 7;%码长
% k = 4;%信息组长度
% num = 100;%BCH数目
% errt = 0.01;
% [genpoly,t] = bchgenpoly(n,k);%生成多项式和纠错能力
% msg = randi([0 1],num,k); %信息每行一个bch
% %msg = [0 1 0 1];
% Gmsg = gf(msg);%转到Galois域
% %最简单的编译码语法结构
% c1 = bchenc(Gmsg,n,k);
% %c1 = bchenc(gf([0 1 0 1]),n,k);
% %c2 = bchenc(gf([0 1 1 1]),n,k);
% %c3 = bchenc(gf([1 1 0 1]),n,k);
% %c4 = bchenc(gf([0 0 1 1]),n,k);


% c2 = reshape(c1',1,num*n);
% %加入噪声
% c2 = c2 + randerr(1,num*n,num*n*errt);
% c2 = c2(randi([1 n]):end);%接收码子起始比特随机


N=20;%分析的码子数
save = 0;%保留的码子
p1 = 0.8;%噪声，剔除码子
p2 = 0.8;%判断码长是否正确

m = 3;
for ml = 3 : 2^m%ml为码长
    for start = 1:ml
        %取N个码子
        c3 = c2(start:start+N*ml-1);
        c4 = reshape(c3,ml,N);
        c5 = c4';
        save = 0;
        %两两算码子的公因式
        for n1 = 1:N
            count = 0;
            for n2 = 1:N
                ggcf = gf2vecgcd(c5(n1,:),c5(n2,:));
                if(length(ggcf)>=m)
                    count = count+1;
                end
            end
            if count/N > p1 %判断阶数的,可剔除误码
                save = save + 1;
                %保存正确码组
            end
        end
        if save/N>p2%判断保留数目
            ml
            start
        end       
    end%start  
end%ml







