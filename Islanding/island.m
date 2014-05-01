classdef island
	%ISLAND methods for detecting and dealing with islanding
	%   methods:
	%      resolve(mCase, networks) resolve mCase into seperate cases
	%			                    defined by 'networks', discarding
	%			                    (shedding) those with no generation.
	%
	%
	%      forkSystem(mCase, busList) from mCase, fork a subsystem with
	%								  only those busses (and associated
	%								  branches) specified in busList.
	%
	%
	%      find(mCase)  traverse the network and identify isolated
	%					groupings of busses.
	
	
	properties
	end
	
	methods
	end
	
	methods(Static)
		
		function [subCases] = resolve(mCase, networks)
		% resolve   handle bus islanding so we can run power flows again
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
				genIsland = intersect(busses, mCase.gen(:,1));
				fork(isle) = any(genIsland);
			end


			% Fork each isolated subsystem that has generation
			subCases = {};
			for isle = find(fork(:)'),
				subCases = [subCases, island.forkSystem(mCase, networks{isle})];
			end
		end
		
		function [mCase] = forkSystem(mCase, busList)
		% forkSystem   fork a subsystem with select busses
		%
		% This function removes all busses and branches from mCase that are not listed
		% in busList. It also removes generator listings and branches
		% connecting to busses that are not in the network
		
			%remove the busses
			keepBusses = false(length(mCase.bus(:,1)),1); %boolean vector of which busses keep
			
			for i = 1:length(busList),
				keepBusses = keepBusses | mCase.bus(:,1) == busList(i);
			end

			mCase.bus = mCase.bus(keepBusses,:);
			
			% fix 'areas'
			if isfield(mCase, 'areas'),
				[nAreas,~] = size(mCase.areas);
				for i = 1:nAreas, %for each area 'relative price bus' listing,

					areaBus = mCase.areas(i,2);

					count = 0;
					while ~any(mCase.bus(:,1) == areaBus), %while areaBus is not in network
						areaBus = areaBus + (count * (-1)^(mod(count,2))); 
						count = count+1;
					end
						% this loop searches around areaBus by checking +1, -1,
						% +2, -2... untill it finds a bus that is in the
						% network.

					mCase.areas(i,2) = areaBus;

				end
			end
			%remove any branches which connect to busses not in the network
			discardBranches = false(length(mCase.branch(:,1)),1);
			for i = 1:length(mCase.branch(:,1)),
				discardBranches(i) = ~(any(mCase.branch(i,1) == busList) && any(mCase.branch(i,2) == busList));
			end
			
			mCase.branch = mCase.branch(~discardBranches, :);

			%discard gen listings
			
			discardGenList = false(length(mCase.gen(:,1)), 1);
			for i = 1:length(mCase.gen(:,1)),
				discardGenList(i) = ~any(mCase.gen(i,1) == busList);
			end
			
			mCase.gen = mCase.gen(~discardGenList, :);
			
			
			%discard bus positions
			if isfield(mCase, 'bus_geo'),
% 				mCase.Xpos = mCase.Xpos(keepBusses);
				mCase.bus_geo = mCase.bus_geo(keepBusses);
			end
% 			if isfield(mCase,'Ypos'),
% 				mCase.Ypos = mCase.Ypos(keepBusses);
% 			end
			
			%discard fault listings
			if isfield(mCase, 'fault'),
				[numFaults, ~] = size(mCase.fault);
				
				discardFaults = false(numFaults, 1);
				
				for fau = 1:numFaults,
					discardFaults(fau) = ~(any(mCase.fault(fau,1) == busList) && any(mCase.fault(fau,2) == busList));
				end
				mCase.fault = mCase.fault(~discardFaults,:);
				
				if isempty(mCase.fault), mCase = rmfield(mCase, 'fault'); end
			
			end
		end
		
		function [networks] = find(mCase, figures, verbose)
		%find   traverse a network to identify isolated busses
		%
		% Given a matpower case, this code explores the network's branch
		% connections to identify isolated busses or groups of busses. It returns a
		% cell array where each element is a collection of busses that are linked
		% to a network.
		%
		% Usage:
		%   [networks] = find(mCase);
		%
		%   [networks] = find(mCase, true); produces a plot of the network
		%   showing all processed elements in red; depends on the case having Xpos
		%   and Ypos values for each bus
		%
		%   [networks] = find(mCase, true, true); steps through the network
		%   exploration, plotting each bus and branch as it is explored and
		%   printing the explored network busses to the command prompt.
		%

		% Written by Anton Lodder in May 2013.
		% 


			%Input handling
			if nargin >2,
				timeDelay = 0.1* verbose; %time delay is zero if verbose is off
			elseif nargin > 1
				verbose = false;
				timeDelay = 0;
			else %nargin == 1;
				timeDelay = 0;
				verbose = false;
				figures = false;
			end


% 			if figures && isfield(mCase, 'fault'), figure; gridPlot(rmfield(mCase,'fault')); end
            
            if figures, 
                close all; 
                figure;
                set(gca,'YDir','reverse');
            end


			[nBusses,~] = size(mCase.bus);
			[nBranches,~] = size(mCase.branch);



			%% Set up some structures to track progress

			visitBus = false(nBusses,1);
			traversedBranch = false(nBranches,1);
				%bool vectors to track which bus/branches have been visited

			busNetworks = zeros(nBusses,1); 
				%indicate the network the bus is in (zero indicates not processed)

			networks = {[]};
				% to track how many isolated sub-networks we have and which busses 
				% are in each

			currentNetwork = 1;
				%keep track of which network the current bus is in.



			

			%% Traverse the network %%%

			if verbose, fprintf('\n\nChecking Network for Islanding:\nTraversing the Network...\n===============================\n'); end

			currentBus = randi(nBusses); %pick a random bus to start on
			while(currentBus > 0),
                
                if currentBus == 29,
                    keyboard
                end


				if visitBus(currentBus), %bus has been visited, find its network
					% check if the branch's network is different from currentNetwork
					if currentNetwork ~= busNetworks(currentBus), %different network, so merge the two
						currentNetwork = mergeNetworks(busNetworks(currentBus), currentNetwork);
					end
				else% visit the bus
					visitBus(currentBus) = true; %mark current bus as visited

% 					networks{currentNetwork}(end+1) = currentBus; %add bus to current network 
					networks{currentNetwork} = [networks{currentNetwork} currentBus];

					busNetworks(currentBus) = currentNetwork; %mark bus's network number
					if verbose, fprintf('\t%s\n',printNetworks(networks)); end
				end


				if figures, hold on; 
					scatter(mCase.bus_geo(currentBus,1), mCase.bus_geo(currentBus,2), 'r', 'Linewidth', 2);
					hold off; pause(timeDelay); 
                end
					%highlight node on map





				% Traverse to next bus

				branches = mCase.branch(:,1) ==currentBus | mCase.branch(:,2) == currentBus;
					%get all branches connected to this bus

				branchIndices = find(branches & ~traversedBranch);
				if ~isempty(branchIndices), %there is atleast one untraversed branch leaving this node
					branch = randi(length(branchIndices)); %pick a random branch

					node = mCase.branch(branchIndices(branch),1:2);
					nextBus = node(node ~=currentBus);
					traversedBranch(branchIndices(branch)) = true; %mark branch as traversed

					if figures, 
						hold on; 
% 						plot(mCase.Xpos([currentBus, nextBus]), mCase.Ypos([currentBus, nextBus]), 'r', 'Linewidth', 2); 
						try
                            branch_geo = mCase.branch_geo{branchIndices(branch)};
                            for i = 1:size(branch_geo,1)-1,
                               plot(branch_geo(i:i+1,1), branch_geo(i:i+1,2), 'r', 'Linewidth',2); 
                            end
% 							plot(mCase.bus_geo([currentBus, nextBus],[1,1]), mCase.bus_geo([currentBus, nextBus],[2,2]), 'r', 'Linewidth', 2);
						catch
							keyboard
						end
						hold off; 	 pause(timeDelay); end
					 %mark traversed path;

					currentBus = nextBus; %update bus.
				else % all branches have been traversed, so try to find an unvisited node
					unVisited = find(~visitBus); %get all unvisited busses

					if isempty(unVisited), %all nodes have been visited
						currentBus = -1; %causes while loop to exit
					else		
						bus = randi(length(unVisited)); 
						currentBus = unVisited(bus); %update bus
						
% 						networks{end+1} = []; %add new empty network
						networks = [networks {[]}];
						
						currentNetwork = length(networks); %set network number

						if figures, 
							hold on; 
% 							plot(mCase.Xpos(currentBus), mCase.Ypos(currentBus), 'g.', 'markersize', 20);
							plot(mCase.bus_geo(currentBus,1), mCase.bus_geo(currentBus,2), 'g.', 'markersize', 20);
							hold off; pause(timeDelay * 6); 
						end		
					end
				end
			end %end of while loop

			%% Go over any untraversed branches to make sure they don't join two isolated networks
			if verbose, fprintf('\n\nChecking remaining branches...\n=================================\n'); end

			remainingBranches = find(~traversedBranch);

			for branchNum = remainingBranches(:)'
				if verbose, fprintf('\tChecking Branch %d.', branchNum); end

				node = mCase.branch(branchNum, 1:2); %get nodes connected by branch
				if busNetworks(node(1)) ~= busNetworks(node(2)), %bus networks are different
					if verbose, fprintf('\tMerging networks %d and %d.',busNetworks(node(1)), busNetworks(node(2))); end;
					mergeNetworks(busNetworks(node(1)), busNetworks(node(2)));
				end

				if verbose, fprintf('\n'); end
				if figures, 
% 					hold on; p = plot(mCase.Xpos(node), mCase.Ypos(node), 'r', 'Linewidth', 2); 
					hold on; p = plot(mCase.bus_geo(node, 1), mCase.bus_geo(node,2), 'r', 'Linewidth', 2);
					set(p, 'Color',[224,103,27]/256);  
					hold off; 	 
					pause(timeDelay); 
				end
			end

			numIslands = length(networks);

			oldNetworks = networks;
			if verbose,
				fprintf('\n\nSummary:\n============\n');
				fprintf('\tNumber of networks: %d\n', numIslands);
			end

			lengths = zeros(1, length(networks));
			for i = 1:length(networks), lengths(i) = length(networks{i}); end
			[~,indices] = sort(lengths, 'descend');
			networks = networks(indices);


			function out = printNetworks(myNetworks)
			%returns a string output of 'networks'
				out = '';
				for i = 1:length(myNetworks)
					sublist = myNetworks{i};
					sublist = sprintf('%d ', sublist);
					out = [out, [sprintf('%d:[',i), sublist(1:end-1), ']'], '   '];
				end
			end



			function currentNetwork = mergeNetworks(n1, n2)
			%merge two networks into one.
				newNetwork = min(n1, n2);%keep the lower network number, discard the older one
				oldNetwork = max(n1, n2);

% 				networks{newNetwork} = union(networks{newNetwork}, networks{oldNetwork});
				networks{newNetwork} = fast_union_sorted(sort(networks{newNetwork}), sort(networks{oldNetwork}));
					%unite networks on lower-numbered network
				networks = networks( 1:length(networks) ~= oldNetwork);
					%delete higher-numbered network
				for i = 1:length(networks),	busNetworks(networks{i}) = i; end
					%update bus network numberings

				currentNetwork = newNetwork; %update network number

				if verbose, fprintf('\t%s\n',printNetworks(networks)); end
			end
		end %find(mCase, figure, verbose);


	
		
		
	end
	
	
	
end

