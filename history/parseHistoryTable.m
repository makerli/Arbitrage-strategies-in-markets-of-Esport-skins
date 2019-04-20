function [itemsHistogramCell, newItems] = parseHistoryTable(C5_t, names)
% 输入1：c5history（table）就是从excel初始导入到matlab的table
% 输入2：名字索引
% 输出1：单列cell，元素是行向量，储存饰品所有的成交价格
% 输出2：newItems 是除去以异常价格交易的数据。但是实际上有很多异常价格。
% 输出3（已废除）：单列向量，每一个饰品每小时成交件数。

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
newItems = cell(length(names), 1);       %newItems 是除去以异常价格交易的数据。但是有更好的方法——用方差的倍乘来作间距
for x = 1 : length(names)
    for i = 1 : length(items{x})
        if items{x}(i) < 2.3 * med(x) && items{x}(i) > 0.3 * med(x)
            newItems{x}(length(newItems{x}) + 1) = items{x}(i);
        end
    end
end


end
