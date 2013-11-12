load CPFcases.mat;


mCase = CPFcases(5); %This case has a single isolated bus with no generation

networks = island.find(mCase);


islandNum = 2;

islandedBusses = networks{islandNum};

runpf(mCase);

genIsland = intersect(islandedBusses, mCase.gen(:,1));



fork = false(length(networks), 1);

for isle = 1:length(networks),
	
	busses = networks{isle};
	genIsland = intersect(busses, mCase.gen(:,1));
	
	fork(isle) = any(genIsland);
	
end


subCases = {};
for isle = find(fork(:)'),
	
	subCases = [subCases, island.forkSystem(mCase, networks{isle})];
	
end
close all;
for i = 1:length(subCases),
	
	figure; gridPlot(subCases{i});
end

fprintf('Number of sub networks: %d\n', length(subCases));