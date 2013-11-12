function subCases = resolveIsland(mCase, networks)
% resolveIsland   handle bus islanding so we can run power flows again
%    This function handles networks where faults have resulted in one or
%    more busses being isolated from the main network. One of two
%    strategies are used:
%
%     * Island has no generation; Shed the load
%     * Island contains generator units; Return a subsystem.


	fork = false(length(networks), 1);

	
	% Identify networks with generation
	for isle = 1:length(networks),
		busses = networks{isle};
		genIsland = intersect(busses, mCase.gen(1,:));
		fork(isle) = any(genIsland);
	end
	
	
	% Fork each isolated subsystem that has generation
	subCases = {};
	for isle = find(fork(:)'),
		subCases = [subCases, island.forkSystem(mCase, networks{isle})];
	end
	
	
	