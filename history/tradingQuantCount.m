function num = tradingQuantCount(quantVec,f)
num = 0;
for i = 1 : size(quantVec)
    if quantVec(i) > f
        num = num + 1;
    end
end
end