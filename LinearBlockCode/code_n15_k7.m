close all;
clear;

%基本参数
n=15;
k=7;
d=5;%分组码最小距离
rate = k/n;%码率

%定义校验矩阵（也可以用MATLAB函数直接生成）
H=[ 1 1 0 1 0 0 0  1 0 0 0 0 0 0 0;
	0 1 1 0 1 0 0  0 1 0 0 0 0 0 0; 
	0 0 1 1 0 1 0  0 0 1 0 0 0 0 0; 
	0 0 0 1 1 0 1  0 0 0 1 0 0 0 0; 
	1 1 0 1 1 1 0  0 0 0 0 1 0 0 0; 
	0 1 1 0 1 1 1  0 0 0 0 0 1 0 0; 
	1 1 1 0 0 1 1  0 0 0 0 0 0 1 0; 
	1 0 1 0 0 0 1  0 0 0 0 0 0 0 1];

%定义生成矩阵
G=[                              
 1 0 0 0 0 0 0  1 0 0 0 1 0 1 1;
 0 1 0 0 0 0 0  1 1 0 0 1 1 1 0;
 0 0 1 0 0 0 0  0 1 1 0 0 1 1 1;
 0 0 0 1 0 0 0  1 0 1 1 1 0 0 0;
 0 0 0 0 1 0 0  0 1 0 1 1 1 0 0;
 0 0 0 0 0 1 0  0 0 1 0 1 1 1 0;
 0 0 0 0 0 0 1  0 0 0 1 0 1 1 1];
%对于汉明码，可以用MATLAB的hammgen函数生成矩阵G和H

%定义仿真参数
ferrlim = 1000;%总帧数
EbNOdb = 0:0.1:10-0.1;%噪声,多几个看效果

for nEN = 1:length(EbNOdb)
  en = 10^(EbNOdb(nEN)/10);
  sigma = 1/sqrt(2*rate*en);
  errs(nEN) = 0;%误比特数
  nferr(nEN) = 0;%误帧数
  nframe = 0;%当前帧
  
   while nframe<ferrlim %传输ferrlim帧
     nframe = nframe + 1;
     msg = randi([0,1],1,k);  %生成随机信息组
     code = Block_encoder(n,k,msg,G); %编码
     
     I = 2*code - 1;%BPSK调制	 
     rec = I + sigma*randn(1,n);%添加噪声
     rec = (sign(rec)+1)/2;%解调，硬判决
     est_code = Block_decoder(n,k,rec,H,d);%译码
     err = length(find(est_code~=code));%统计误比特率
     errs(nEN) = errs(nEN) +err;%误比特率
     if err
		nferr(nEN) = nferr(nEN)+1;%误帧数
     end
   end
	errs(nEN) = errs(nEN)/nframe/n;%当前的误码率
	nferr(nEN) = nferr(nEN)/nframe;%当前的误帧率
    fprintf('信噪比为%f时 误码率=%f  误帧率=%f  \n', EbNOdb(nEN),errs(nEN),nferr(nEN));
    plot(EbNOdb(1:length(errs)),errs);
    pause(1);
end




function code = Block_encoder(n,k,msg,G)
%输入
%n：码字长度
%k：信息组长度
%msg,编码输入信息组
%输岀
%code：編码输出码字

    [M,N] = size(G);%获取生成矩阵的维数
    if N~=n
       disp('Parameter of Code Length is error.\n');
    end
    if M~=k
       disp('Parameter of Info. Length is error.\n');
    end
    %计算編码输出
    code = rem(msg*G,2);%模2
    
end

function est_code = Block_decoder(n,k,rec,H,d)
%输入
%n：码字长度
%k：信息组长度
%rec：译码器接收的磧判决码字
%H：分组码的校验矩阵
%d：分组码的最小距离
%输出
%est_code：译码输出码字

    [M,N] = size (H);
    if N~=n
       disp('Parameter of Code Length is error.\n');
    end
    if M~=n-k
       disp('Parameter of Parity Length is error.\n');
    end
    t=fix((d-1)/2);%纠正t个随机错误
    %初始化并计算不同个数H矩阵列向量的所有组合的个数
    num = zeros(1,t);
    for idx = 1:t
       num(idx) = factorial(n)/factorial(n-idx)/factorial(idx);
    end%计算纠正1~t个错误的需要H矩阵列向量的组合数

    maxnum = max(num);  %计算最大组合数
    out = zeros(t,maxnum,t);%分配空间;第1位代表纠几位，第2位代表错误图样个数，第3位代表每个错误图样里的错误
    out(1,1:num(1),1) = 1:n;%单个H列向量索引
    out = compound(out,n,num,t,1);%2到t个H列向量组合的所有可能索引集合
    
    est_code = rec;%如果超出纠错能力则不进行纠错，原样输出

    Hcom = zeros(1,n-k);    %初始化H组合列向量
    E = zeros(1,N); %初始化错误图样
    S = rem(rec*H',2);  %计算伴随式
    if find(S)  %伴随式不为零，表示码子中有错
        for err=1:t %在分组码的纠错能力范围内，查找与伴随式值匹配的H列向量或器组合。
            %从1位错误开始纠错
           for idx=1:num(err) %逐个检查H列向量组合。检查所有的错误图样
               Hcom = zeros(1, n-k);
               for j = 1:err %计算H组合列向量；针对具体的错误图样包含err个错码
                  Hcom = rem(Hcom + H(:,out(err,idx,j))',2);
               end
               %Hcom为对应H的列加和
               if(sum(rem(S+Hcom, 2)) == 0) %找到匹配的H列向量组合
                  E(out(err,idx,1:err)) = 1;    %估计错误图样，设置E对应的列为1
                  est_code = rem(rec+E, 2); %纠错
                  return;
               end
           end
        end
    else %无错，直接输出
        est_code = rec;
    end
end

%计算伴随式组合函数
function out = compound(out, n, num, d, idx)
% d,纠错最大数
% n,码长度
% num, 存储了所有可能的组合数
    if idx == d
        return;
    end

    flag= 1;
    cnt = 1;
    for i=1:num(idx) %组合数
        for j=out(idx,i,idx)+1:n
           for k=1:idx %纠错数目
               if(j==out(idx, i, idx))
                   flag =0;
               end
           end
           if flag
               out (idx+1,cnt,1:idx) = out (idx,i,1:idx);
               out(idx+1,cnt,idx+1) = j;
               cnt = cnt+1;
           end
        end
    end

    idx = idx+1;
    out = compound(out,n,num,d,idx);
end




