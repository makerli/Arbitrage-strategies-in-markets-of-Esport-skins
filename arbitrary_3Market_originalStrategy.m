function [cash, investment] = arbitrary_3Market_originalStrategy(inventory, C5_matrix, igxe_matrix, bitskin_matrix, tradingQuantPerHour , strategy)

%���ԣ�ͬʱ���ף�����������  ����ȫ���ڿ�������ȡ�ص����������������

%%
%�����ʽ���
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
%��ʼ��
investment = 0;
C5 = 111;             %��־����
IGXE = 222;           %��־����
BITSKIN = 333;        %��־����
timeFlag = 1;      %����ʱ�����
cash = 0;       %����ֽ�
t = size(C5_matrix,2);    %��ʱ��
lowPriceFlag = C5;  %��ʾ�ĸ��г��۸����
sellFlag = BITSKIN; %��ʾ�����ĸ��г��ҳ�
buyFlag = BITSKIN;
pendingFlag = false;   %�����0����ôû���������ᣬ�����1�����������Ტ�ڹҳ�
items = cell(size(C5_matrix,1),1);     %items��Ԫ�����飬��������Ʒ��������ÿ��Ԫ����1*n�������� n��ÿ����Ʒ�Ŀ����
for ii = 1 : length(items)
    items{ii} = zeros(1, inventory(ii));
    investment = investment + inventory(ii) * min([C5_matrix(ii,1), igxe_matrix(ii,1), bitskin_matrix(ii,1)]);
end
depletion_home = 0.015;  % ���۵��������� 1.5%  �������������г����ǣ� �������ת��Ϊ���������Ĳ�������
depletion_oversea = 0.049;  %bitskin���۵��������� 4.9%

%%
%��������
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
    fprintf('��Ʒ���: %d     ', x);
    fprintf('�򷽣�%s   ������%s  ', buyString, sellString);
    fprintf('��ۣ�%d�� ���ۣ�%d�� ��ǰ�ֽ�%d    ���ʣ�%3.5f    ��ǰ��棺', round(buyPrice), round(sellPrice), cash, possib);
    disp(items{x});
    fprintf('%c%c', 8, 8);%ɾ��2�����з�
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
    %���������ʵ�������һ��Сʱ֮�ڣ�����۸����˽��ܲ��ҹ���ĸ���
    %TODO �������������buyFlag
    possib = possibility(xx, timeFlag, M_F);
    if rand(1) < possib          %TODO TODO TODO ��Ҫ���ɹ��Ƹ��ʵĺ���
        costTemp = buy(buyFlag, xx, index);
        revenueTemp = sell(sellFlag, xx);
        printTransaction(buyFlag, sellFlag, costTemp, revenueTemp, cash, xx, possib);
    end
end
%%
% ������ѭ����ڡ��� %
for i = 1 : t
    fprintf('\n��ǰʱ�㣺%d\n', i);
    timeFlag = i;
    for k = 1 : length(items)
        for kk = 1 : length(items{k})
            if items{k}(kk) ~= 0
                items{k}(kk) = items{k}(kk) - 1;
            end
        end
    end
    
    for x = 1 : size(C5_matrix,1)
        %%%  Original Start ���� Original Start ���� Original Start ���� Original Start 
        if (C5_matrix(x,i) - igxe_matrix(x,i)) < 0
            lowPriceFlag = C5;
            %TODO ����ʶ���������ᣬ���Ҵ�ŵ���־������
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
            %TODO ����ʶ���������ᣬ���Ҵ�ŵ���־������
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
        end % Original �ж����������Ƿ���ڡ�������
        %transactionPending()�����д���buyFlag
        if pendingFlag == 1
            if checkFeasibility(x) ~= -1
                transcationPending(x, checkFeasibility(x), timeFlag, sellFlag);
            end
        end
        %%%  Original End ���� Original End ���� Original End ���� Original End
    end
end
end









