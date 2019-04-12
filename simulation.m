cash = zeros(100,1);
revenue = zeros(100,1);
revenue_combined = zeros(100,1);
investment = 0;
inv = 2*ones(41,1);
inv(1) = 0;
mean_cash = (-1)*ones(30,1);
std_cash = (-1)*ones(30,1);
mean_revenue = (-1)*ones(30,1);
std_revenue = (-1)*ones(30,1);
mean_revenue_combined = (-1)*ones(30,1);
std_revenue_combined = (-1)*ones(30,1);
% strategy = 0.30;
k = 1;
for strategy = 0.01 : 0.01 : 0.30
    for i = 1 : 100
        [cash(i), investment] = arbitrary_3Market_originalStrategy(inv, C5, IGXE, BITSKIN, tradingQuantPerHour , strategy);
        [revenue(i), ~, ~, ~,~ , ~] = arbitrary_3Market_noiseStrategy(inv, C5, IGXE, BITSKIN, tradingQuantPerHour, strategy);
        [revenue_combined(i), ~, ~] = arbitrary_3Market_combinedStrategy(inv, C5, IGXE, BITSKIN, tradingQuantPerHour, strategy);
    end
    mean_cash(k) = mean(cash);
    std_cash(k) = std(cash);
    mean_revenue(k) = mean(revenue);
    std_revenue(k) = std(revenue);
    mean_revenue_combined(k) = mean(revenue_combined);
    std_revenue_combined(k) = std(revenue_combined);
    k = k+1;
end
% fprintf('mean_cash: %4.1f   std_cash: %4.1f\n', mean(cash), std(cash));
% fprintf('mean_revenue: %4.1f   std_revenue: %4.1f\n', mean(revenue), std(revenue));
% fprintf('mean_revenue_combined: %4.1f   std_revenue_combined: %4.1f\n', mean(revenue_combined), std(revenue_combined));
