function save42figures(BITSKIN, IGXE, C5, NAMES)

[n, m] = size(BITSKIN);
t = 1 : 1: m ; 
for i = 1 : n
    h = figure;
    plot(t, C5(i, :), 'LineWidth', 1.3);
    hold on
    plot(t, IGXE(i, :), 'LineWidth', 1.3);
    hold on
    plot(t, BITSKIN(i, :), 'LineWidth', 1.3);
    legend('C5', 'IGXE', 'BITSKIN');
    title(NAMES(i, 1));
    fileName = ['P-No', mat2str(i), '.fig'];
    savefig(h, fileName);
    close;
end

end