function [TROPF, countMatrix, corrVec, percentage] = checkCorrelation(items, C5_matrix, fractionNum, definitionOfCorr)

timeRangeOnPriceFraction = cell(size(C5_matrix,1), fractionNum);
TROPF = timeRangeOnPriceFraction;
countMatrix = zeros(size(C5_matrix,1), fractionNum);
corrVec = zeros(size(C5_matrix,1), 1);
% priceVec = zeros(size(C5_matrix, 1), 2);

for x = 1 : size(C5_matrix,1)
    minP = min(C5_matrix(x,:));
    maxP = max(C5_matrix(x,:));
    gap = (maxP + 0.05 - minP) / fractionNum;
%     priceVec(x,1) = minP;
%     priceVec(x,2) = gap;
    for fraction = 1 : fractionNum
        for i = 1 : size(C5_matrix, 2)
            if ( C5_matrix(x,i) >= (minP + (fraction-1)*gap) ) && ( C5_matrix(x,i) < (minP + fraction*gap) )
                TROPF{x, fraction}(length(TROPF{x, fraction}) + 1) = i;
            end
        end
    end
end

for x = 1 : size(C5_matrix, 1)
    minP = min(C5_matrix(x,:));
    maxP = max(C5_matrix(x,:));
    gap = (maxP + 0.05 - minP) / fractionNum;
    for frac = 1 : fractionNum
        for ii = 1 : length(TROPF{x, frac})
            for jj = 1 : length(items{x})
                if TROPF{x, frac}(ii) == items{x}(1,jj)
%                     if ( items{x}(2,jj) >= (minP + (fraction-1)*gap) ) && ( items{x}(2,jj) < (minP + fraction*gap) )
                        countMatrix(x, frac) = countMatrix(x, frac) + 1;
%                     end
                end
            end
        end
    end
end

for x = 1 : size(C5_matrix, 1)
    for frac = 1 : fractionNum
        countMatrix(x,frac) = countMatrix(x,frac) / length(TROPF{x,frac});
        if isempty(TROPF{x, frac})
            countMatrix(x,frac) = 0;
        end
    end
end

counter = 0;
for x = 1 : size(C5_matrix,1)
    series1 = countMatrix(x,:);
    series2 = 1 : 1 : fractionNum;
    R = corrcoef(series1, series2);
    corrVec(x) = R(1,2);
    if corrVec(x) < ( - definitionOfCorr)
        counter = counter + 1;
    end
end
percentage = counter / size(C5_matrix, 1);

end