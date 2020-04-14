function b = isDivisible(f,g)
% �ж϶�Ԫ�� GF(2) ����������ʽ��������ϵ
% �� 'f' ���Ա� 'g' �������򷵻� 1�����򷵻� 0;
% ����
% f: ����ʽ���� '0' �� '1' ��ɵ��ַ�������ʾ
% g: ��ʽ���� '0' �� '1' ��ɵ��ַ�������ʾ
% ���
% �� 'g' ���� 'f'������� 1��������� 0
%
% �������ʽΪ 0���򷵻� true (1)
if isempty(find(f,'1'))
    b = true;
    return;
end
% ȥ���ߴε� 0 ϵ��
pos = find(f=='1',1);
f = f(pos:length(f));
len_f = length(f);
% ����ʽ�Ƿ�Ϊ��
if isempty(find(g=='1'))
    error('Error: f is divided by 0')
end
% ȥ���ߴε� 0 ϵ��
pos = find(g=='1',1);
g = g(pos:length(g));
len_g = length(g);
% ������ʽ�Ĵ���С�ڳ�ʽ�Ĵ��������ز�������
b = false;
if len_f < len_g
    return;
end
% ����
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
% �����ʽ�Ƿ�Ϊ 0
b = true;
for i=len_f-len_g+1:len_f
    if f(i) == '1'
        b = false;
        break;
    end
end

end

