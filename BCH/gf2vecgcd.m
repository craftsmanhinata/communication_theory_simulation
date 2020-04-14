function [gys] = gf2vecgcd(s1,s2)
%GF2VECGCD 此处显示有关此函数的摘要
%   求GF(2)上两个多项式的公因式，用辗转相除法
%如果s2全零，s1即为所求
if any(s2,'all')==false
    %disp('s2全零');
    gys = s1;
    return;
else
    %去掉头上的非零
    for i = 1:length(s1)
        if s1(i)==1
            break;
        end
    end
    s1 = s1(i:end);
    for j = 1:length(s2)
        if s2(j)==1
            break;
        end
    end
    s2 = s2(j:end);
    [tmp, s3] = deconv(s1,s2);
    gys = gf2vecgcd(s2,s3);
end

end

