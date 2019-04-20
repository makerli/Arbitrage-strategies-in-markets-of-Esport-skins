function [MA_C5, MA_IGXE, MA_BITSKIN] = movAvg_indie(C5_f, IGXE_f, BITSKIN_f, windowSize)
    %TODO 去不了前windowSize内的噪点，而且windowSize的选择也很有艺术
    b = (1/windowSize) * ones(1, windowSize);
    [nn, mm] = size(C5_f);
    MA_C5 = ones(nn,mm);
    MA_IGXE = ones(nn,mm);
    MA_BITSKIN = ones(nn,mm);
    for e = 1 : nn
        MA_C5(e,:) = filter(b, 1, C5_f(e,:));
        MA_IGXE(e,:) = filter(b, 1, IGXE_f(e,:));
        MA_BITSKIN(e,:) = filter(b ,1, BITSKIN_f(e,:));
        for q = 1 : 23
            w = ones(1,q)/q;
            MA_C5(e,q) = w * C5_f(e, 1:q)';
            MA_IGXE(e,q) = w * IGXE_f(e, 1:q)';
            MA_BITSKIN(e,q) = w * BITSKIN_f(e, 1:q)';
        end
%         MA_C5(i, 1:(windowSize-1)) = C5_f(i, 1:(windowSize-1));
%         MA_IGXE(i, 1:(windowSize-1)) = IGXE_f(i, 1:(windowSize-1));
%         MA_BITSKIN(i, 1:(windowSize-1)) = BITSKIN_f(i, 1:(windowSize-1));
    end
end