clc;
close all;
clear;

%��������
n=15;%�볤
k=7;%��Ϣ�鳤��
d=5;%�����С����
t=2;%����λ��
rate = k/n;%����

%����MATLAB�����������ɶ���ʽϵ��
g = cyclpoly(15,7);
%g = cyclpoly(15,7,'all');

   
%����(15,7)ϵͳѭ��������ɾ���
%���Ǳ�ɵ�����֮������ɾ��󣬲�����ѭ����λ���ԡ�
G=[
1 0 0 0 0 0 0  1 1 1 0 1 0 0 0 ;
0 1 0 0 0 0 0  0 1 1 1 0 1 0 0 ;
0 0 1 0 0 0 0  0 0 1 1 1 0 1 0 ;
0 0 0 1 0 0 0  0 0 0 1 1 1 0 1 ;
0 0 0 0 1 0 0  1 1 1 0 0 1 1 0 ;
0 0 0 0 0 1 0  0 1 1 1 0 0 1 1 ;
0 0 0 0 0 0 1  1 1 0 1 0 0 0 1 ];
%�������Ա任���б任,���Ա任Ϊ����Ŀ���ѭ����λ����ʽ
G1=[
1 0 0 0 0 0 0  1 1 1 0 1 0 0 0 ;
0 1 0 0 0 0 0  0 1 1 1 0 1 0 0 ;
0 0 1 0 0 0 0  0 0 1 1 1 0 1 0 ;
0 0 0 1 0 0 0  0 0 0 1 1 1 0 1 ;
1 0 0 0 1 0 0  0 0 0 0 1 1 1 0 ;
0 1 0 0 0 1 0  0 0 0 0 0 1 1 1 ;
1 0 1 0 0 0 1  0 0 0 0 0 0 1 1 ];
%���������ʽ����
G20=[
1 0 0 0 1 0 1  1 1 0 0 0 0 0 0;
0 1 0 0 0 1 0  1 1 1 0 0 0 0 0;
0 0 1 0 0 0 1  0 1 1 1 0 0 0 0;
0 0 0 1 0 0 0  1 0 1 1 1 0 0 0;
0 0 0 0 1 0 0  0 1 0 1 1 1 0 0;
0 0 0 0 0 1 0  0 0 1 0 1 1 1 0;    
0 0 0 0 0 0 1  0 0 0 1 0 1 1 1];
%��ɵ��;���
G21=[
1 0 0 0 0 0 0  1 0 0 0 1 0 1 1;
0 1 0 0 0 0 0  1 1 0 0 1 1 1 0;
0 0 1 0 0 0 0  0 1 1 0 0 1 1 1;
0 0 0 1 0 0 0  1 0 1 1 1 0 0 0;
0 0 0 0 1 0 0  0 1 0 1 1 1 0 0;
0 0 0 0 0 1 0  0 0 1 0 1 1 1 0;    
0 0 0 0 0 0 1  0 0 0 1 0 1 1 1];

%����������
ferrlim = 100;
EbNOdb = [4.0];

for nEN = 1:length(EbNOdb)
   en = 10^(EbNOdb(nEN)/10);
   sigma = 1/sqrt(2*rate*en);
   errs(nEN) = 0;
   nferr(nEN) = 0;
   nframe = 0;

   %����ferrlim������
   while nframe<ferrlim
     nframe = nframe + 1;%��¼��ǰ����
     msg = randi([0 1],1,k);%���������Ϣ��
     code = rem(msg*G,2);%����
     I=2*code-1;%BPSK ���� W'
     rec = I + sigma*randn(1,n);%�������
     rec = (sign(rec)+1)/2;%�����Ӳ�о�
     est_code = Cyclic_decoder(n, k, rec,g,t);%����
     err = length(find(est_code ~= code));%ͳ��ı������
     errs(nEN) = errs(nEN) +err;
     if err
        nferr(nEN) = nferr(nEN)+1;%ͳ��������
     end
   end
errs(nEN) = errs(nEN)/nframe/n;
nferr(nEN) = nferr(nEN)/nframe;

end
errs
nferr









function code = Cyclic_encoder(n, k, msg, g)
%����
% n���볤
% k����Ϣ�鳤��
% msg����������Ϣ��
% g�����ɶ���ʽ��ϵ��
%���
% code��ѭ����ı������

%��1�ֱ��뷽��������ʽ�˷�
code = zeros(1,n);         %��ʼ���������
code = rem(conv(msg, g), 2); %����

%��2�ֱ��뷽�����������ɾ����þ���˷�ʵ�ֱ���
code = zeros (1,n);         %��ʼ���������
g_len = length (g);         %������ɶ���ʽ�ĳ���
if g_len~=n-k+1
  disp('length of genertaor polynomial is error');
end

G=zeros(k,n);%��ʼ�����ɾ���
%�������ɶ���ʽϵ��ѭ����λ�������ɾ���
for i=1:k
   G(i,:) = [zeros(1, i-1) g zeros(1, n-g_len-(i-1))];
end
%�þ���˷����� 
code = rem(msg*G,2);


%��3�ֱ��뷽��
%��ͼ4.3.2��ʾ�����·ʵ��
code = zeros (1,n);                   %��ʼ�����ɾ���
msg1 = [msg zeros(1,n-k) ] ;       %����Ϣ��󲹳� n-k �� 0
shift_register = zeros (1, g_len-1); %��ʼ����λ�Ĵ���
for i=1:n
   code(i) = rem(g(1)*msg1(i) + sum(shift_register .* g(2:g_len)),2);%�����Ԫ
   for j=1:g_len-2
     shift_register(g_len-j) = shift_register(g_len-j-1);
   end
   shift_register(1) = msg1(i) %���µ�1����λ�Ĵ�����ֵ
end


%��4�ֱ��뷽��
%��ͼ4.3.1��ʾ�����·ʵ��
code = zeros (1,n);                %��ʼ�����ɾ���
for i=1:fix(g_len/2)               %�����ɶ���ʽϵ������
   tmp = g(i);
   g(i) = g(g_len-i+1);
   g (g_len-i+1) = tmp;
end
shift_register = zeros (1,g_len-1); %��ʼ����λ�Ĵ���
for i=1:k                                                   
   code(i) = rem(shift_register(g_len-1)+g(g_len)*msg(i),2); %�����Ԫ
   for j=1:g_len-2
      shift_register(g_len-j) =
      rem(shift_register(g_len-j-1)+g(glen-j)*msg(i),2); %��λ�Ĵ�
   end
   shift_register(1) = g(1)*msg(i);
end
for i=1:n-k
   code(i+k) = shift_register (g_len-i);  %������ֵĺ�n-kλ
end

%��5�ֱ��뷽��(ϵͳ�룬ϵͳλ�����ֵĺ�kλ)
%��MATLAB����ʵ��
code = encode(msg, n, k, 'cyclic', g);
end


function est_code = Cyclic_decoder(n,k,rec,g,t)
%����
%n���볤
%k����Ϣ�鳤��
%rec�����������յ�Ӳ�о�����
%g�� (n,k)ѭ��������ɶ���ʽϵ��
%t�� (n,k)ѭ����ľ�������
%���
%est_code�������������

%�������ɶ���ʽϵ�������ĳ���.��������Ƿ�ƥ��
g_len = length(g);
if g_len~=n-k+1
  disp('length of^genertaor polynomial is error');
end

shift_register = zeros (1,g_len-1);%��ʼ������ʽ�����·����λ�Ĵ���
cache_mem = zeros(1,n); %��ʼ��n+(n-k)=n��������
flag = 1;%������

%��������������n������Ͱ���ʽ�����·
for i=1:n
   %���뻺�棬��λ��ǰ
   for j=1:n-1
     cache_mem (n-j+1) = cache_mem(n-j);
   end
   cache_mem(1) = rec(i);

   %����ʽ�����·�����������λ�Ĵ�����ֵ�������ʽ
   tmp = shift_register(g_len-1);
   for j=1:g_len-2
     shift_register(g_len-j ) = rem(shift_register(g_len-j-1)+...
          tmp*g(g_len-j),2);
   end
   
 
  shift_register(1) = rem(rec(i)+tmp*g(1), 2);
end
%��������ȫ���������ʽ�����·�󣬼���õ�SO,��ʱ��λ�Ĵ��������ݾ��ǰ���ʽ��ֵ

%�жϰ���ʽ�������Ƿ�С�����ھ�������t
if sum(shift_register)<=t
  %�ô���ͼ��(����ʽ)���������ڻ����и�λ��ǰ����˴������ڻ����1�� n-kλ
  cache_mem = [rem(cache_mem(1:n-k)+shift_register, 2)...
  cache_mem(n-k+1:n)];
  %��λn�������������
  for i=1:n
     est_code(i) = cache_mem(n-i+l);
  end
else %����ʽ����������������������λn����������ݺͰ���ʽ�����·����λ�Ĵ���������
 i =1;
   while i<n & flag
      %n�������ѭ����λ
      tmp1 = cache_mem(n);
      for j=1:n-1
         cache_mem(n-j+1) = cache_mem(n-j);
      end
      cache_mem(1) = tmp1;
      %����ʽ�����ѭ����λ
    tmp = shift_register(g_len-1);
for j=1:g_len-2
shift_register(g_len-j) = rem(shift_register (g_len-j-1) +...
tmp*g(g_len-j),2);
end
shift_register(1) = tmp*g(1);
%ÿ��λһ�κ��жϰ���ʽ�������Ƿ�С�ڵ��ھ������� 
if sum(shift_register)<=t
%���д������������ֵĺ�n-kλ���ù��ƵĴ���ͼ���������˳�whileѭ�� 
cache_mem=[rem(cache_mem(1:n-k)+shift_register, 2)...
    cache_mem(n-k+1:n)];
flag = 0;
end
i=i+1;
end 
i=i-l;
if flag %�޷�iEȷ����.�������Ϊȫ��
disp('decoder failed'); 
est_code = zeros(1,n); 
else
%��n�������е����ݼ���ѭ����λn-i�Σ��ָ�����˳��
for j=1:n-i
tmp1 = cache_mem(n); 
for j=1:n-1
cache_mem(n-j+1) = cache_mem(n-j);
end
cache_mem(1) = tmp1;
end
%��λn�������������
for i=1:n
est_code(i)= cache_mem(n-i+1);
end
end
end
end
%---------------------------------���ǿɰ���ҳ��ָ���-------------------------------------

