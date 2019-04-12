function [revenue, cash, investment, noiseMark_C5, noiseMark_IGXE, noiseMark_BITSKIN] = arbitrary_3Market_noiseStrategy(inventory, C5_matrix, igxe_matrix, bitskin_matrix, tradingQuantPerHour, strategy)

%策略：纯粹的噪点交易，当识别出噪点的时候，买入，同时等待被卖出。当一对交易完成之后，才识别下一个噪点并买入。

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
[ma_C5, ma_igxe, ma_bitskin] = movAvg(C5_matrix, igxe_matrix, bitskin_matrix, 24);
noiseMark_C5 = zeros(n_C5, m_C5);
noiseMark_IGXE = zeros(n_C5, m_C5);
noiseMark_BITSKIN = zeros(n_C5, m_C5);
noiseRec = zeros(n_C5, 1);
noisePending = zeros(n_C5, 1);
noisePriceTemp = 10000 * ones(n_C5, 1);
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

function cost = buyOnNoiseStrategy(flag, xx)
    len = length(items{xx});
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
    items{xx}(len+1) = 168;
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

function revenue = sellOnNoiseStrategy(flag, xx, index)
    revenue = sell(flag, xx);
    rowTemp = zeros(1, length(items{xx}) - 1);
    jjj = 1;
    for iii = 1 : length(items{xx})
        if iii == index
        else
            rowTemp(jjj) = items{xx}(iii);
            jjj = jjj + 1;
        end
    end
    items{xx} = rowTemp;
%     rowTemp = zeros(1, size(items{xx},2));
%     jjj = 1;
%     for iii = 1 : size(items{xx},2)
%         if iii == index
%         else
%             rowTemp(jjj) = items{xx}(iii);
%             jjj = jjj + 1;
%         end
%     end
%     items{xx} = rowTemp;
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

function M_flag = feasibleMarketToSellOn(xx, time)
    if C5_matrix(xx, time) < igxe_matrix(xx, time)
        if bitskin_matrix(xx, time) > C5_matrix(xx, time)
            M_flag = BITSKIN;
        else
            M_flag = C5;
        end
    else
        if bitskin_matrix(xx, time) > igxe_matrix(xx, time)
            M_flag = BITSKIN;
        else
            M_flag = IGXE;
        end
    end
end

function [MA_C5, MA_IGXE, MA_BITSKIN] = movAvg(C5_f, IGXE_f, BITSKIN_f, windowSize)
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

function printNoiseTransaction(BS_F, xx, M_F, BS_Amount, possib)
    if class(M_F) == 'string'
        MM_F = M_F;
    else
        if M_F == IGXE
            MM_F = "IGXE";
        elseif M_F == C5
            MM_F = "C5";
        else
            MM_F = "BITSKIN";
        end
    end
    if BS_F == "buy"
        fprintf('噪点购入：编号 %d ,市场 %s ,金额 %d   概率 %3.5f', xx, MM_F, BS_Amount, possib);
        fprintf('当前库存：');
        disp(items{xx});
        fprintf('%c%c \n', 8, 8); %删掉2个换行符
    elseif BS_F == "sell"
        fprintf('噪点售出：编号 %d ,市场 %s ,金额 %d   概率 %3.5f', xx, MM_F, BS_Amount, possib);
        fprintf('当前库存：');
        disp(items{xx});
        fprintf('%c%c \n', 8, 8); %删掉2个换行符
    end
end

function itemsValueCheck()
    totalValue = 0;
    for p = 1 : length(items)
        totalValue = totalValue + min([C5_matrix(p,1), igxe_matrix(p,1), bitskin_matrix(p,1)]) * length(items{p}); 
    end
    fprintf('\n\n现库存总价值：%d\n', totalValue);
    fprintf('现金：%d\n', cash);
    fprintf('资产总价值：%d\n',totalValue+cash);
    fprintf('初始投入：%d\n',investment);
    revenue = totalValue - investment + cash;
end

function printTransaction(buyF, sellF, buyPrice, sellPrice, cash, xx)
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
    fprintf('饰品编号: %d     ', xx);
    fprintf('买方：%s   卖方：%s  ', buyString, sellString);
    fprintf('买价：%d， 卖价：%d， 当前现金：%d   当前库存：', round(buyPrice), round(sellPrice), cash);
    disp(items{xx});
    fprintf('%c%c', 8, 8);%删掉2个换行符
    fprintf('    %s\n', nameLookUp(xx));
end

function transcationPending(xx, index)
    %这个函数其实处理的是一个小时之内，这个价格有人接受并且购买的概率
    %TODO 如果卖出，处理buyFlag
    if rand(1) < possibility(xx, timeFlag, sellFlag)          %TODO TODO TODO 需要换成估计概率的函数
        costTemp = buy(buyFlag, xx, index);
        revenueTemp = sell(sellFlag, xx);
        printTransaction(buyFlag, sellFlag, costTemp, revenueTemp, cash, xx);
    end
end

function buildNoiseMark(noiseTIME, noiseFLAG, xx)
    if noiseFLAG == C5
        noiseMark_C5(xx, noiseTIME) = 100;
    elseif noiseFLAG == IGXE
        noiseMark_IGXE(xx, noiseTIME) = 100;
    elseif noiseFLAG == BITSKIN
        noiseMark_BITSKIN(xx, noiseTIME) = 100;
    end
end

function noiseTransactionPending(timeNow, xx, noise_F)
    possib = 0;
    if noiseRec(xx) == 1 && noisePending(xx) == 0
        noisePriceTemp(xx) = buyOnNoiseStrategy(noise_F, xx);   %TODO 这里的修改记住的PriceTemp冲突
        noisePending(xx) = 1;
        printNoiseTransaction("buy", xx, noise_F, noisePriceTemp(xx), 1);
    end
    if feasibleMarketToSellOn(xx, timeNow) == C5
        if C5_matrix(xx, timeNow) > noisePriceTemp(xx) * (1+strategy)     %如果满足卖出的差价条件
            possib = possibility(xx, timeNow, C5);
            if rand(1) < possib
                if checkFeasibility(xx) ~= -1
                    revenueTemp = sellOnNoiseStrategy(C5, xx, checkFeasibility(xx));
                    noisePending(xx) = 0;
                    printNoiseTransaction("sell", xx, "C5", revenueTemp, possib);
                end
            end
        end
    elseif feasibleMarketToSellOn(xx, timeNow) == IGXE
        if igxe_matrix(xx, timeNow) > noisePriceTemp(xx) * (1+strategy)
            possib = possibility(xx, timeNow, IGXE);
            if rand(1) < possib
                if checkFeasibility(xx) ~= -1
                    revenueTemp = sellOnNoiseStrategy(IGXE, xx, checkFeasibility(xx));
                    noisePending(xx) = 0;
                    printNoiseTransaction("sell", xx, "IGXE", revenueTemp, possib);
                end
            end
        end
    else
        if bitskin_matrix(xx, timeNow) > noisePriceTemp(xx) * (1+strategy)
            possib = possibility(xx, timeNow, BITSKIN);
            if rand(1) < possib
                if checkFeasibility(xx) ~= -1
                    revenueTemp = sellOnNoiseStrategy(BITSKIN, xx, checkFeasibility(xx));
                    noisePending(xx) = 0;
                    printNoiseTransaction("sell", xx, "BITSKIN", revenueTemp, possib);
                end
            end
        end
    end
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

%%
% ★★★主循环入口★★★ 
% for i = 1 : t       
%     fprintf('\n当前时点：%d\n', i);
%     timeFlag = i;
%     for k = 1 : length(items)
%         for kk = 1 : length(items{k})
%             if items{k}(kk) ~= 0
%                 items{k}(kk) = items{k}(kk) - 1;
%             end
%         end
%     end
%     
%     for x = 1 : size(C5_matrix,1)
%         if (C5_matrix(x,i) - igxe_matrix(x,i)) < 0
%             lowPriceFlag = C5;
%             %TODO 在这识别套利机会，并且存放到标志变量上
%             if (bitskin_matrix(x,i)*( 1 - depletion_oversea ) - C5_matrix(x,i)) > (bitskin_matrix(x,i) + C5_matrix(x,i))/2 * strategy
%                 sellFlag = BITSKIN;
%                 buyFlag = C5;
%                 pendingFlag = true;
%             elseif (C5_matrix(x,i)*( 1 - depletion_home ) - bitskin_matrix(x,i)) > (bitskin_matrix(x,i) + C5_matrix(x,i))/2 * strategy
%                 sellFlag = C5;
%                 buyFlag = BITSKIN;
%                 pendingFlag = true;
%             else
%                 pendingFlag = false;
%             end
%                 
%                     
%         else
%             lowPriceFlag = IGXE;
%             %TODO 在这识别套利机会，并且存放到标志变量上
%             if (bitskin_matrix(x,i)*( 1 - depletion_oversea) - igxe_matrix(x,i)) > (bitskin_matrix(x,i) + igxe_matrix(x,i))/2 * strategy
%                 sellFlag = BITSKIN;
%                 buyFlag = IGXE;
%                 pendingFlag = true;
%             elseif (igxe_matrix(x,i)*( 1 - depletion_home) - bitskin_matrix(x,i)) > (bitskin_matrix(x,i) + igxe_matrix(x,i))/2 * strategy
%                 sellFlag = IGXE;
%                 buyFlag = BITSKIN;
%                 pendingFlag = true;
%             else
%                 pendingFlag = false;
%             end
%         end %判断套利机会是否存在——结束
%         %transactionPending()函数中处理buyFlag
%         if pendingFlag == 1
%             if checkFeasibility(x) ~= -1
%                 transcationPending(x, checkFeasibility(x));
%             end
%         end
%     end
% end
%%
%噪点策略
%★★★主循环入口★★★
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
        if( (min([ma_C5(x,i), ma_igxe(x,i), ma_bitskin(x,i)]) - min([C5_matrix(x,i), igxe_matrix(x,i), bitskin_matrix(x,i)])) > min([ma_C5(x,i), ma_igxe(x,i), ma_bitskin(x,i)]) * 0.035)
            noiseTime = i;
            noiseRec(x) = 1;
            if C5_matrix(x,i) < igxe_matrix(x,i)
                if C5_matrix(x,i) < bitskin_matrix(x,i)
                    noiseFlag = C5;
%                     noisePriceTemp(x) = C5_matrix(x,i);
                else
                    noiseFlag = BITSKIN;
%                     noisePriceTemp(x) = bitskin_matrix(x,i);
                end
            else
                if igxe_matrix(x,i) < bitskin_matrix(x,i)
                    noiseFlag = IGXE;
%                     noisePriceTemp(x) = igxe_matrix(x,i);
                else
                    noiseFlag = BITSKIN;
%                     noisePriceTemp(x) = bitskin_matrix(x,i);
                end
            end
            buildNoiseMark(noiseTime, noiseFlag, x);  %TODO 写这个函数
        else
            noiseRec(x) = 0;
        end  %以上，识别噪点
        if (noiseRec(x)==1) || (noisePending(x)==1)         %注意当 noiseRec 和 noisePending 同时为 true 的时候，可能是两种情况
                                                            %一是前面的噪点没处理完，又来一个噪点
                                                            %二是持续的噪点
            noiseTransactionPending(i, x, noiseFlag);
        end
    end
end
itemsValueCheck();
end









