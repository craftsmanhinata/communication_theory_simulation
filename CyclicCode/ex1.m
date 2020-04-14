clc;
close all;
clear;

%基本参数
n=15;%码长
k=7;%信息组长度
d=5;%码的最小距离
t=2;%纠错位数
rate = k/n;%码率

%利用MATLAB函数计算生成多项式系数
g = cyclpoly(15,7);
%g = cyclpoly(15,7,'all');

   
%构造(15,7)系统循环码的生成矩阵
%这是变成典型阵之后的生成矩阵，不满足循环移位特性。
G=[
1 0 0 0 0 0 0  1 1 1 0 1 0 0 0 ;
0 1 0 0 0 0 0  0 1 1 1 0 1 0 0 ;
0 0 1 0 0 0 0  0 0 1 1 1 0 1 0 ;
0 0 0 1 0 0 0  0 0 0 1 1 1 0 1 ;
0 0 0 0 1 0 0  1 1 1 0 0 1 1 0 ;
0 0 0 0 0 1 0  0 1 1 1 0 0 1 1 ;
0 0 0 0 0 0 1  1 1 0 1 0 0 0 1 ];
%经过线性变换，行变换,可以变换为下面的可以循环移位的形式
G1=[
1 0 0 0 0 0 0  1 1 1 0 1 0 0 0 ;
0 1 0 0 0 0 0  0 1 1 1 0 1 0 0 ;
0 0 1 0 0 0 0  0 0 1 1 1 0 1 0 ;
0 0 0 1 0 0 0  0 0 0 1 1 1 0 1 ;
1 0 0 0 1 0 0  0 0 0 0 1 1 1 0 ;
0 1 0 0 0 1 0  0 0 0 0 0 1 1 1 ;
1 0 1 0 0 0 1  0 0 0 0 0 0 1 1 ];
%根据码多项式生成
G20=[
1 0 0 0 1 0 1  1 1 0 0 0 0 0 0;
0 1 0 0 0 1 0  1 1 1 0 0 0 0 0;
0 0 1 0 0 0 1  0 1 1 1 0 0 0 0;
0 0 0 1 0 0 0  1 0 1 1 1 0 0 0;
0 0 0 0 1 0 0  0 1 0 1 1 1 0 0;
0 0 0 0 0 1 0  0 0 1 0 1 1 1 0;    
0 0 0 0 0 0 1  0 0 0 1 0 1 1 1];
%变成典型矩阵
G21=[
1 0 0 0 0 0 0  1 0 0 0 1 0 1 1;
0 1 0 0 0 0 0  1 1 0 0 1 1 1 0;
0 0 1 0 0 0 0  0 1 1 0 0 1 1 1;
0 0 0 1 0 0 0  1 0 1 1 1 0 0 0;
0 0 0 0 1 0 0  0 1 0 1 1 1 0 0;
0 0 0 0 0 1 0  0 0 1 0 1 1 1 0;    
0 0 0 0 0 0 1  0 0 0 1 0 1 1 1];

%定义仿真参数
ferrlim = 100;
EbNOdb = [4.0];

for nEN = 1:length(EbNOdb)
   en = 10^(EbNOdb(nEN)/10);
   sigma = 1/sqrt(2*rate*en);
   errs(nEN) = 0;
   nferr(nEN) = 0;
   nframe = 0;

   %发送ferrlim个码组
   while nframe<ferrlim
     nframe = nframe + 1;%记录当前码组
     msg = randi([0 1],1,k);%生成随机信息组
     code = rem(msg*G,2);%编码
     I=2*code-1;%BPSK 调制 W'
     rec = I + sigma*randn(1,n);%添加噪声
     rec = (sign(rec)+1)/2;%解调，硬判决
     est_code = Cyclic_decoder(n, k, rec,g,t);%译码
     err = length(find(est_code ~= code));%统计谋比特率
     errs(nEN) = errs(nEN) +err;
     if err
        nferr(nEN) = nferr(nEN)+1;%统计误字率
     end
   end
errs(nEN) = errs(nEN)/nframe/n;
nferr(nEN) = nferr(nEN)/nframe;

end
errs
nferr









function code = Cyclic_encoder(n, k, msg, g)
%输入
% n：码长
% k：信息组长度
% msg：待编码信息组
% g；生成多项式的系数
%输出
% code：循环码的编码输出

%第1种编码方法：多项式乘法
code = zeros(1,n);         %初始化输出码字
code = rem(conv(msg, g), 2); %编码

%第2种编码方法：构造生成矩阵，用矩阵乘法实现编码
code = zeros (1,n);         %初始化输出码字
g_len = length (g);         %检査生成多项式的长度
if g_len~=n-k+1
  disp('length of genertaor polynomial is error');
end

G=zeros(k,n);%初始化生成矩阵
%根据生成多项式系数循环移位构造生成矩阵
for i=1:k
   G(i,:) = [zeros(1, i-1) g zeros(1, n-g_len-(i-1))];
end
%用矩阵乘法编码 
code = rem(msg*G,2);


%第3种编码方法
%用图4.3.2所示编码电路实现
code = zeros (1,n);                   %初始化生成矩阵
msg1 = [msg zeros(1,n-k) ] ;       %在信息组后补充 n-k 个 0
shift_register = zeros (1, g_len-1); %初始化移位寄存器
for i=1:n
   code(i) = rem(g(1)*msg1(i) + sum(shift_register .* g(2:g_len)),2);%输出码元
   for j=1:g_len-2
     shift_register(g_len-j) = shift_register(g_len-j-1);
   end
   shift_register(1) = msg1(i) %更新第1个移位寄存器的值
end


%第4种编码方法
%用图4.3.1所示编码电路实现
code = zeros (1,n);                %初始化生成矩阵
for i=1:fix(g_len/2)               %将生成多项式系数逆序
   tmp = g(i);
   g(i) = g(g_len-i+1);
   g (g_len-i+1) = tmp;
end
shift_register = zeros (1,g_len-1); %初始化移位寄存器
for i=1:k                                                   
   code(i) = rem(shift_register(g_len-1)+g(g_len)*msg(i),2); %输出码元
   for j=1:g_len-2
      shift_register(g_len-j) =
      rem(shift_register(g_len-j-1)+g(glen-j)*msg(i),2); %移位寄存
   end
   shift_register(1) = g(1)*msg(i);
end
for i=1:n-k
   code(i+k) = shift_register (g_len-i);  %输出码字的后n-k位
end

%第5种编码方法(系统码，系统位在码字的后k位)
%用MATLAB函数实现
code = encode(msg, n, k, 'cyclic', g);
end


function est_code = Cyclic_decoder(n,k,rec,g,t)
%输入
%n：码长
%k：信息组长度
%rec：译码器接收的硬判决码字
%g： (n,k)循环码的生成多项式系数
%t： (n,k)循环码的纠错能力
%输出
%est_code：译码输出码字

%计算生成多项式系数向量的长度.检验参数是否匹配
g_len = length(g);
if g_len~=n-k+1
  disp('length of^genertaor polynomial is error');
end

shift_register = zeros (1,g_len-1);%初始化伴随式计算电路的移位寄存器
cache_mem = zeros(1,n); %初始化n+(n-k)=n级缓存器
flag = 1;%纠错标记

%将接收码字移入n级缓存和伴随式计算电路
for i=1:n
   %移入缓存，高位在前
   for j=1:n-1
     cache_mem (n-j+1) = cache_mem(n-j);
   end
   cache_mem(1) = rec(i);

   %伴随式计算电路根据输入和移位寄存器的值计算伴随式
   tmp = shift_register(g_len-1);
   for j=1:g_len-2
     shift_register(g_len-j ) = rem(shift_register(g_len-j-1)+...
          tmp*g(g_len-j),2);
   end
   
 
  shift_register(1) = rem(rec(i)+tmp*g(1), 2);
end
%接收码字全部移入伴随式计算电路后，计算得到SO,此时移位寄存器的内容就是伴随式的值

%判断伴随式的重最是否小于零于纠错能力t
if sum(shift_register)<=t
  %用错误图样(伴随式)纠错，由于在缓存中高位在前，因此错误集中在缓存的1： n-k位
  cache_mem = [rem(cache_mem(1:n-k)+shift_register, 2)...
  cache_mem(n-k+1:n)];
  %移位n次输出译码码字
  for i=1:n
     est_code(i) = cache_mem(n-i+l);
  end
else %伴随式重量不満足条件，继续移位n级缓存的内容和伴随式计算电路的移位寄存器的内容
 i =1;
   while i<n & flag
      %n级缓存的循环移位
      tmp1 = cache_mem(n);
      for j=1:n-1
         cache_mem(n-j+1) = cache_mem(n-j);
      end
      cache_mem(1) = tmp1;
      %伴随式计算的循环移位
    tmp = shift_register(g_len-1);
for j=1:g_len-2
shift_register(g_len-j) = rem(shift_register (g_len-j-1) +...
tmp*g(g_len-j),2);
end
shift_register(1) = tmp*g(1);
%每移位一次后，判断伴随式的重量是否小于等于纠错能力 
if sum(shift_register)<=t
%所有错误集中在了码字的后n-k位，用估计的错误图样纠错，并退出while循环 
cache_mem=[rem(cache_mem(1:n-k)+shift_register, 2)...
    cache_mem(n-k+1:n)];
flag = 0;
end
i=i+1;
end 
i=i-l;
if flag %无法iE确纠错.译码输出为全零
disp('decoder failed'); 
est_code = zeros(1,n); 
else
%将n级缓存中的内容继续循环移位n-i次，恢复正常顺序
for j=1:n-i
tmp1 = cache_mem(n); 
for j=1:n-1
cache_mem(n-j+1) = cache_mem(n-j);
end
cache_mem(1) = tmp1;
end
%移位n次输出译码码字
for i=1:n
est_code(i)= cache_mem(n-i+1);
end
end
end
end
%---------------------------------我是可爱的页面分割线-------------------------------------

