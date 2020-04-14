close all;
clear;

%��������
n=15;
k=7;
d=5;%��������С����
rate = k/n;%����

%����У�����Ҳ������MATLAB����ֱ�����ɣ�
H=[ 1 1 0 1 0 0 0  1 0 0 0 0 0 0 0;
	0 1 1 0 1 0 0  0 1 0 0 0 0 0 0; 
	0 0 1 1 0 1 0  0 0 1 0 0 0 0 0; 
	0 0 0 1 1 0 1  0 0 0 1 0 0 0 0; 
	1 1 0 1 1 1 0  0 0 0 0 1 0 0 0; 
	0 1 1 0 1 1 1  0 0 0 0 0 1 0 0; 
	1 1 1 0 0 1 1  0 0 0 0 0 0 1 0; 
	1 0 1 0 0 0 1  0 0 0 0 0 0 0 1];

%�������ɾ���
G=[                              
 1 0 0 0 0 0 0  1 0 0 0 1 0 1 1;
 0 1 0 0 0 0 0  1 1 0 0 1 1 1 0;
 0 0 1 0 0 0 0  0 1 1 0 0 1 1 1;
 0 0 0 1 0 0 0  1 0 1 1 1 0 0 0;
 0 0 0 0 1 0 0  0 1 0 1 1 1 0 0;
 0 0 0 0 0 1 0  0 0 1 0 1 1 1 0;
 0 0 0 0 0 0 1  0 0 0 1 0 1 1 1];
%���ں����룬������MATLAB��hammgen�������ɾ���G��H

%����������
ferrlim = 1000;%��֡��
EbNOdb = 0:0.1:10-0.1;%����,�༸����Ч��

for nEN = 1:length(EbNOdb)
  en = 10^(EbNOdb(nEN)/10);
  sigma = 1/sqrt(2*rate*en);
  errs(nEN) = 0;%�������
  nferr(nEN) = 0;%��֡��
  nframe = 0;%��ǰ֡
  
   while nframe<ferrlim %����ferrlim֡
     nframe = nframe + 1;
     msg = randi([0,1],1,k);  %���������Ϣ��
     code = Block_encoder(n,k,msg,G); %����
     
     I = 2*code - 1;%BPSK����	 
     rec = I + sigma*randn(1,n);%�������
     rec = (sign(rec)+1)/2;%�����Ӳ�о�
     est_code = Block_decoder(n,k,rec,H,d);%����
     err = length(find(est_code~=code));%ͳ���������
     errs(nEN) = errs(nEN) +err;%�������
     if err
		nferr(nEN) = nferr(nEN)+1;%��֡��
     end
   end
	errs(nEN) = errs(nEN)/nframe/n;%��ǰ��������
	nferr(nEN) = nferr(nEN)/nframe;%��ǰ����֡��
    fprintf('�����Ϊ%fʱ ������=%f  ��֡��=%f  \n', EbNOdb(nEN),errs(nEN),nferr(nEN));
    plot(EbNOdb(1:length(errs)),errs);
    pause(1);
end




function code = Block_encoder(n,k,msg,G)
%����
%n�����ֳ���
%k����Ϣ�鳤��
%msg,����������Ϣ��
%���
%code�������������

    [M,N] = size(G);%��ȡ���ɾ����ά��
    if N~=n
       disp('Parameter of Code Length is error.\n');
    end
    if M~=k
       disp('Parameter of Info. Length is error.\n');
    end
    %���㾎�����
    code = rem(msg*G,2);%ģ2
    
end

function est_code = Block_decoder(n,k,rec,H,d)
%����
%n�����ֳ���
%k����Ϣ�鳤��
%rec�����������յĴ��о�����
%H���������У�����
%d�����������С����
%���
%est_code�������������

    [M,N] = size (H);
    if N~=n
       disp('Parameter of Code Length is error.\n');
    end
    if M~=n-k
       disp('Parameter of Parity Length is error.\n');
    end
    t=fix((d-1)/2);%����t���������
    %��ʼ�������㲻ͬ����H������������������ϵĸ���
    num = zeros(1,t);
    for idx = 1:t
       num(idx) = factorial(n)/factorial(n-idx)/factorial(idx);
    end%�������1~t���������ҪH�����������������

    maxnum = max(num);  %������������
    out = zeros(t,maxnum,t);%����ռ�;��1λ�������λ����2λ�������ͼ����������3λ����ÿ������ͼ����Ĵ���
    out(1,1:num(1),1) = 1:n;%����H����������
    out = compound(out,n,num,t,1);%2��t��H��������ϵ����п�����������
    
    est_code = rec;%����������������򲻽��о���ԭ�����

    Hcom = zeros(1,n-k);    %��ʼ��H���������
    E = zeros(1,N); %��ʼ������ͼ��
    S = rem(rec*H',2);  %�������ʽ
    if find(S)  %����ʽ��Ϊ�㣬��ʾ�������д�
        for err=1:t %�ڷ�����ľ���������Χ�ڣ����������ʽֵƥ���H������������ϡ�
            %��1λ����ʼ����
           for idx=1:num(err) %������H��������ϡ�������еĴ���ͼ��
               Hcom = zeros(1, n-k);
               for j = 1:err %����H�������������Ծ���Ĵ���ͼ������err������
                  Hcom = rem(Hcom + H(:,out(err,idx,j))',2);
               end
               %HcomΪ��ӦH���мӺ�
               if(sum(rem(S+Hcom, 2)) == 0) %�ҵ�ƥ���H���������
                  E(out(err,idx,1:err)) = 1;    %���ƴ���ͼ��������E��Ӧ����Ϊ1
                  est_code = rem(rec+E, 2); %����
                  return;
               end
           end
        end
    else %�޴�ֱ�����
        est_code = rec;
    end
end

%�������ʽ��Ϻ���
function out = compound(out, n, num, d, idx)
% d,���������
% n,�볤��
% num, �洢�����п��ܵ������
    if idx == d
        return;
    end

    flag= 1;
    cnt = 1;
    for i=1:num(idx) %�����
        for j=out(idx,i,idx)+1:n
           for k=1:idx %������Ŀ
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




