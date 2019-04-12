function [items, tradingQuantPerHour] = historyCell(C5_t, names)
% 输入1：c5history（table）就是从excel初始导入到matlab的table
% 输入2：名字索引
% 输出1：单列cell，元素是2行的矩阵，上面一行是时点（化成整数型，跟走势图兼容的），下面一行是价格
% 输出2：单列向量，每一个饰品每小时成交件数。

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

tradingQuantPerHour = countVec / (3*7*24);  %因为历史记录是4月7日导出的，刚好3个星期

end