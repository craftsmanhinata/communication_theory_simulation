function [gys] = gf2vecgcd(s1,s2)
%GF2VECGCD �˴���ʾ�йش˺�����ժҪ
%   ��GF(2)����������ʽ�Ĺ���ʽ����շת�����
%���s2ȫ�㣬s1��Ϊ����
if any(s2,'all')==false
    %disp('s2ȫ��');
    gys = s1;
    return;
else
    %ȥ��ͷ�ϵķ���
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

