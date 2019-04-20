function [itemsHistogramCell, newItems] = parseHistoryTable(C5_t, names)
% ����1��c5history��table�����Ǵ�excel��ʼ���뵽matlab��table
% ����2����������
% ���1������cell��Ԫ������������������Ʒ���еĳɽ��۸�
% ���2��newItems �ǳ�ȥ���쳣�۸��׵����ݡ�����ʵ�����кܶ��쳣�۸�
% ���3���ѷϳ���������������ÿһ����ƷÿСʱ�ɽ�������

items = cell(length(names), 1);
% tradingQuantPerHour = zeros(length(names), 1);

for x = 1 : length(names)
    for i = 1 : size(C5_t, 1)
        if table2array(C5_t(i,1)) == names(x)
            items{x}(length(items{x}) + 1) = table2array(C5_t(i,2));
        end
    end
%     tradingQuantPerHour(x) = length(items{x}) / (3*7*24);
end
itemsHistogramCell = items;

stdvar = zeros(length(items),1);
for x = 1 : length(items)
    stdvar(x) = std(items{x});
end

med = zeros(length(items),1);
for x = 1 : length(items)
    med(x) = median(items{x});
end
newItems = cell(length(names), 1);       %newItems �ǳ�ȥ���쳣�۸��׵����ݡ������и��õķ��������÷���ı����������
for x = 1 : length(names)
    for i = 1 : length(items{x})
        if items{x}(i) < 2.3 * med(x) && items{x}(i) > 0.3 * med(x)
            newItems{x}(length(newItems{x}) + 1) = items{x}(i);
        end
    end
end


end
