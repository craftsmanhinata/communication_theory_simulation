function b = isDivisible(f,g)
% 判断二元域 GF(2) 上两个多项式的整除关系
% 若 'f' 可以被 'g' 整除，则返回 1；否则返回 0;
% 输入
% f: 被除式，由 '0' 和 '1' 组成的字符串来表示
% g: 除式，由 '0' 和 '1' 组成的字符串来表示
% 输出
% 若 'g' 整除 'f'，则输出 1；否则，输出 0
%
% 如果被除式为 0，则返回 true (1)
if isempty(find(f,'1'))
    b = true;
    return;
end
% 去除高次的 0 系数
pos = find(f=='1',1);
f = f(pos:length(f));
len_f = length(f);
% 检查除式是否为零
if isempty(find(g=='1'))
    error('Error: f is divided by 0')
end
% 去除高次的 0 系数
pos = find(g=='1',1);
g = g(pos:length(g));
len_g = length(g);
% 若被除式的次数小于除式的次数，返回不可整除
b = false;
if len_f < len_g
    return;
end
% 除法
for i = 1:len_f-len_g+1
    if f(i) == '0'
        continue;
    end
    for j=1:len_g
        if f(i+j-1) == g(j)
            f(i+j-1) = '0';
        else
            f(i+j-1) = '1';
        end
    end
end
% 检查余式是否为 0
b = true;
for i=len_f-len_g+1:len_f
    if f(i) == '1'
        b = false;
        break;
    end
end

end

