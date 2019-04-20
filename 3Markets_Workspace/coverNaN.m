for i = 1 : 44
    for j = 1 : 325
        if isnan(BITSKIN(i,j))
            BITSKIN(i,j) = BITSKIN(i,j-1);
        end
        if isnan(C5(i,j))
            C5(i,j) = C5(i,j-1);
        end
        if isnan(IGXE(i,j))
            IGXE(i,j) = IGXE(i,j-1);
        end
    end
end