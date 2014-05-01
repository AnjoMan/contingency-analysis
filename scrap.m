
base = loadcase('case30_mod.mat')




figure; hold on;
scatter( base.bus_geo(:,1), base.bus_geo(:,2));

for i = 1:length(base.branch_geo)
   branch = base.branch_geo{i};
   
   for j = 1:size(branch,1)-1
      plot(branch(j:j+1,1), branch(j:j+1,2)) 
   end
end