ml = 7;
start = 5;
c3 = c2(start:start+N*ml-1);
c4 = reshape(c3,ml,N);
c5 = c4';
save = 0;
sc = gf(zeros(N,ml));
%���������ӵĹ���ʽ
for n1 = 1:N
    count = 0;
    for n2 = 1:N
        ggcf = gf2vecgcd(c5(n1,:),c5(n2,:));
        if(length(ggcf)>=m)
            count = count+1;
        end
    end
    if count/N > 0.8 %�жϽ�����,���޳�����
        save = save + 1;
        %������ȷ����
        sc(save,:) = c5(n1,:);
    end
end

%�޳��������ӵõ�sc������ʽ
gg = sc(1,:);
for ii = 2:save
    gg = gf2vecgcd(gg,sc(ii,:))    
end










