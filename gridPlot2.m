close all

base = loadcase('case30_mod.mat');






figure;

hold on;

% base.bus_geo = [base.bus_geo(:,1), -base.bus_geo(:,2)];
for i = 1:length(base.branch_geo),
    
    branches = base.branch_geo{i};
    
    for j = 1:size(branches,1)-1,
        plot(branches(j:j+1, 1), -branches(j:j+1,2));
    end
    
end
scatter(base.bus_geo(:,1), -base.bus_geo(:,2), ones(length(base.bus_geo),1)*150, 'r.');




