function num = tradingQuantCount(quantVec,f)
%������tradingQuantPerHour  ��  f
%tradingQuantPerHour������ historyCell.m �ϵĺ����������
% f ���û������ÿСʱ����������ֵ
% ����ǳ����û��������ֵ������
num = 0;
for i = 1 : size(quantVec)
    if quantVec(i) > f
        num = num + 1;
    end
end
end