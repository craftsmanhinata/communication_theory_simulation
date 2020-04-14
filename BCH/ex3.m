ml = 7;
start = 5;
c3 = c2(start:start+N*ml-1);
c4 = reshape(c3,ml,N);
c5 = c4';
save = 0;
sc = gf(zeros(N,ml));
%两两算码子的公因式
for n1 = 1:N
    count = 0;
    for n2 = 1:N
        ggcf = gf2vecgcd(c5(n1,:),c5(n2,:));
        if(length(ggcf)>=m)
            count = count+1;
        end
    end
    if count/N > 0.8 %判断阶数的,可剔除误码
        save = save + 1;
        %保存正确码组
        sc(save,:) = c5(n1,:);
    end
end

%剔除误码码子得到sc，求公因式
gg = sc(1,:);
for ii = 2:save
    gg = gf2vecgcd(gg,sc(ii,:))    
end










