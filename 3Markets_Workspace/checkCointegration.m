function [h, pValue] = checkCointegration(C5, IGXE, BITSKIN, higherLevel)
h = zeros(size(C5,1),2);
pValue = zeros(size(C5,1),2);
counter1 = 0;
counter2 = 0;
counter3 = 0;
counter4 = 0;
counter5 = 0;
for i = 1 : size(C5,1)
    Y = [C5(i,:)', IGXE(i,:)'];
    [h(i,1), pValue(i,1)] = egcitest(Y);
    Y = [C5(i,:)', BITSKIN(i,:)'];
    [h(i,2), pValue(i,2)] = egcitest(Y);
    if pValue(i,1) < pValue(i,2)
        counter1 = counter1 + 1;
    end
    if h(i,1) == 1
        counter2 = counter2 + 1;
    end
    if h(i,2) == 1
        counter3 = counter3 + 1;
    end
    if pValue(i,1) < higherLevel
        counter4 = counter4 + 1;
    end
    if pValue(i,2) < higherLevel
        counter5 = counter5 + 1;
    end
end

fprintf('以 0.95 为置信水平下:\n国内协整数量：%d    国内外协整数量：%d,  国内pValue < 国内外pValue 数量：%d\n', counter2, counter3, counter1);
fprintf('以 %d 为置信水平下:\n国内协整数量：%d   国内外协整数量：%d\n',1-higherLevel, counter4, counter5);
end