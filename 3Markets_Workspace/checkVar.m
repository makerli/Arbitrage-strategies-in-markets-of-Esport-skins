function [stdValue, counter] = checkVar(C5, IGXE, BITSKIN)
distance = cell(1,size(C5,1));
% distance = zeros(3, size(C5,2));
stdValue = zeros(size(C5,1),3);
counter = 0;
for x = 1 : size(C5,1)
    for t = 1 : size(C5,2)
        distance{x}(1,t) = C5(x,t) - IGXE(x,t);
        distance{x}(2,t) = C5(x,t) - BITSKIN(x,t);
        distance{x}(3,t) = IGXE(x,t) - BITSKIN(x,t);
    end
    stdValue(x,1) = std(distance{x}(1,:));
    stdValue(x,2) = std(distance{x}(2,:));
    stdValue(x,3) = std(distance{x}(3,:));
    if stdValue(x,1) < std(x,2) && stdValue(x,1) < std(x,3)
        counter = counter + 1;
    end
end
end
