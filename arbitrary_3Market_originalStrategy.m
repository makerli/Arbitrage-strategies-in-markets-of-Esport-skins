function [cash, investment] = arbitrary_3Market_originalStrategy(inventory, C5_matrix, igxe_matrix, bitskin_matrix, tradingQuantPerHour , strategy)

%策略：同时交易（先卖，后买）  并且全部在可以立即取回的情况下卖出和买入

%%
%输入格式检查
[n_C5,m_C5] = size(C5_matrix);
[n_igxe, m_igxe] = size(igxe_matrix);
[n_BS, m_BS] = size(bitskin_matrix);
if ([n_C5, m_C5]==[n_igxe, m_igxe])*[1;1] ~= 2
    fprintf('ERROR MESSAGE : sizes of C5 and igxe matrix do not match');
    return;
end
if ([n_C5, m_C5]==[n_BS, m_BS])*[1;1] ~= 2
    fprintf('ERROR MESSAGE : sizes of C5 and igxe matrix do not match');
    return;
end
if length(inventory) ~= n_C5
    fprintf('ERROR MESSAGE : size of inventory does not match with price matrix');
    return
end
if size(strategy)*[1;1] ~= 2
    fprintf('ERROR MESSAGE : argument strategy must be a secular');
    return
end
%%
%初始化
investment = 0;
C5 = 111;             %标志变量
IGXE = 222;           %标志变量
BITSKIN = 333;        %标志变量
timeFlag = 1;      %运行时间进度
cash = 0;       %库存现金
t = size(C5_matrix,2);    %总时间
lowPriceFlag = C5;  %显示哪个市场价格更低
sellFlag = BITSKIN; %显示该在哪个市场挂出
buyFlag = BITSKIN;
pendingFlag = false;   %如果是0，那么没有套利机会，如果是1，有套利机会并在挂出
items = cell(size(C5_matrix,1),1);     %items是元胞数组，长度是饰品种类数，每个元胞是1*n行向量， n是每种饰品的库存量
for ii = 1 : length(items)
    items{ii} = zeros(1, inventory(ii));
    investment = investment + inventory(ii) * min([C5_matrix(ii,1), igxe_matrix(ii,1), bitskin_matrix(ii,1)]);
end
depletion_home = 0.015;  % 出售的手续费是 1.5%  对于两个国内市场都是， 这个可以转化为整个函数的参数输入
depletion_oversea = 0.049;  %bitskin出售的手续费是 4.9%

%%
%辅助函数
function cost = buy(flag, xx, index) 
    if flag == C5
        cost = C5_matrix(xx, timeFlag);
        cash = cash - cost;
    elseif flag == IGXE
        cost = igxe_matrix(xx, timeFlag);
        cash = cash - cost;
    elseif flag == BITSKIN
        cost = bitskin_matrix(xx, timeFlag);
        cash = cash - cost;
    end
    items{xx}(index) = 168;
end


function revenue = sell(flag, xx)
    if flag == C5
        revenue = C5_matrix(xx, timeFlag) * ( 1 - depletion_home );
        cash = cash + revenue;
    elseif flag == IGXE
        revenue = igxe_matrix(xx, timeFlag) * ( 1 - depletion_home );
        cash = cash + revenue;
    elseif flag == BITSKIN
        revenue = bitskin_matrix(xx, timeFlag) * ( 1 - depletion_oversea );
        cash = cash + revenue;
    end
end


function index = checkFeasibility(xx)
    index = -1;
    for j = 1 : length(items{xx})
        if items{xx}(j) == 0
            index = j;
            return
        end
    end
end


function printTransaction(buyF, sellF, buyPrice, sellPrice, cash, xx, possib)
    if buyF == IGXE
        buyString = 'IGXE';
    elseif buyF == C5
        buyString = 'C5';
    elseif buyF == BITSKIN
        buyString = 'BITSKIN';
    end
    if sellF == IGXE
        sellString = 'IGXE';
    elseif sellF == C5
        sellString = 'C5';
    elseif sellF == BITSKIN
        sellString = 'BITSKIN';
    end
    fprintf('饰品编号: %d     ', x);
    fprintf('买方：%s   卖方：%s  ', buyString, sellString);
    fprintf('买价：%d， 卖价：%d， 当前现金：%d    概率：%3.5f    当前库存：', round(buyPrice), round(sellPrice), cash, possib);
    disp(items{x});
    fprintf('%c%c', 8, 8);%删掉2个换行符
    fprintf('    %s\n', nameLookUp(x));
end

function p = possibility(xx, timeNow, M_F)
    if M_F == BITSKIN
        priceee = bitskin_matrix(xx,timeNow);
        MAX = max(bitskin_matrix(xx,:));
        MIN = min(bitskin_matrix(xx,:));
        tt = tradingQuantPerHour(xx) / tradingQuantPerHour(23) * ((priceee - MIN)/(MAX-MIN)*7 + 1);
    elseif M_F == C5
        priceee = C5_matrix(xx,timeNow);
        MAX = max(C5_matrix(xx,:));
        MIN = min(C5_matrix(xx,:));
        tt = tradingQuantPerHour(xx) / tradingQuantPerHour(23) * ((priceee - MIN)/(MAX-MIN)*4 + 1);
    elseif M_F == IGXE
        priceee = igxe_matrix(xx,timeNow);
        MAX = max(igxe_matrix(xx,:));
        MIN = min(igxe_matrix(xx,:));
        tt = ((priceee - MIN)/(MAX-MIN)*7 + 1);
    end
    p = 0.639*exp(-0.2224*tt) * tradingQuantPerHour(xx) / tradingQuantPerHour(23);
end

function transcationPending(xx, index, timeFlag, M_F)
    %这个函数其实处理的是一个小时之内，这个价格有人接受并且购买的概率
    %TODO 如果卖出，处理buyFlag
    possib = possibility(xx, timeFlag, M_F);
    if rand(1) < possib          %TODO TODO TODO 需要换成估计概率的函数
        costTemp = buy(buyFlag, xx, index);
        revenueTemp = sell(sellFlag, xx);
        printTransaction(buyFlag, sellFlag, costTemp, revenueTemp, cash, xx, possib);
    end
end
%%
% ★★★主循环入口★★★ %
for i = 1 : t
    fprintf('\n当前时点：%d\n', i);
    timeFlag = i;
    for k = 1 : length(items)
        for kk = 1 : length(items{k})
            if items{k}(kk) ~= 0
                items{k}(kk) = items{k}(kk) - 1;
            end
        end
    end
    
    for x = 1 : size(C5_matrix,1)
        %%%  Original Start —— Original Start —— Original Start —— Original Start 
        if (C5_matrix(x,i) - igxe_matrix(x,i)) < 0
            lowPriceFlag = C5;
            %TODO 在这识别套利机会，并且存放到标志变量上
            if (bitskin_matrix(x,i)*( 1 - depletion_oversea ) - C5_matrix(x,i)) > (bitskin_matrix(x,i) + C5_matrix(x,i))/2 * strategy
                sellFlag = BITSKIN;
                buyFlag = C5;
                pendingFlag = true;
            elseif (C5_matrix(x,i)*( 1 - depletion_home ) - bitskin_matrix(x,i)) > (bitskin_matrix(x,i) + C5_matrix(x,i))/2 * strategy
                sellFlag = C5;
                buyFlag = BITSKIN;
                pendingFlag = true;
            else
                pendingFlag = false;
            end  
        else
            lowPriceFlag = IGXE;
            %TODO 在这识别套利机会，并且存放到标志变量上
            if (bitskin_matrix(x,i)*( 1 - depletion_oversea) - igxe_matrix(x,i)) > (bitskin_matrix(x,i) + igxe_matrix(x,i))/2 * strategy
                sellFlag = BITSKIN;
                buyFlag = IGXE;
                pendingFlag = true;
            elseif (igxe_matrix(x,i)*( 1 - depletion_home) - bitskin_matrix(x,i)) > (bitskin_matrix(x,i) + igxe_matrix(x,i))/2 * strategy
                sellFlag = IGXE;
                buyFlag = BITSKIN;
                pendingFlag = true;
            else
                pendingFlag = false;
            end
        end % Original 判断套利机会是否存在——结束
        %transactionPending()函数中处理buyFlag
        if pendingFlag == 1
            if checkFeasibility(x) ~= -1
                transcationPending(x, checkFeasibility(x), timeFlag, sellFlag);
            end
        end
        %%%  Original End —— Original End —— Original End —— Original End
    end
end
end









