function num = tradingQuantCount(quantVec,f)
%输入是tradingQuantPerHour  和  f
%tradingQuantPerHour可以用 historyCell.m 上的函数计算出来
% f 是用户定义的每小时交易数量阈值
% 输出是超过用户定义的阈值的数量
num = 0;
for i = 1 : size(quantVec)
    if quantVec(i) > f
        num = num + 1;
    end
end
end