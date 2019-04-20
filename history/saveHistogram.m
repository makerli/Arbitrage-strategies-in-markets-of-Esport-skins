function saveHistogram(items)

for i = 1 : length(items)
    h = figure;
    hist(items{i}, 18);
    fileName = ['No', mat2str(i), 'h.fig'];
    savefig(h, fileName);
    close;
end

end