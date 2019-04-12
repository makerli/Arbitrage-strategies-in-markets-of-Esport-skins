function [items, tradingQuantPerHour] = historyCell(C5_t, names)
% ����1��c5history��table�����Ǵ�excel��ʼ���뵽matlab��table
% ����2����������
% ���1������cell��Ԫ����2�еľ�������һ����ʱ�㣨���������ͣ�������ͼ���ݵģ�������һ���Ǽ۸�
% ���2������������ÿһ����ƷÿСʱ�ɽ�������

items = cell(length(names), 1);
originPoint = datetime(2019, 3, 17, 21, 0, 0);

countVec = zeros(length(names),1);
for x = 1 : length(names)
    for i = 1 : size(C5_t, 1)
        if table2array(C5_t(i,1)) == names(x)
            timePoint = table2array(C5_t(i,3)) + table2array(C5_t(i,4));
            duration = timePoint - originPoint;
            time = day(duration) * 24 + hour(duration);
            items{x}(1, size(items{x}, 2) + 1) = time;
            items{x}(2, size(items{x}, 2)) = table2array(C5_t(i,2));
            
            if items{x}(1, size(items{x}, 2)) > 0
                countVec(x) = countVec(x) + 1;
            end
        end
    end
end

tradingQuantPerHour = countVec / (3*7*24);  %��Ϊ��ʷ��¼��4��7�յ����ģ��պ�3������

end