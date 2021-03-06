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
                %these store by index, not by id

			busNetworks = zeros(nBusses,1); 
				%indicate the network the bus is in at any given time(zero indicates not processed)
                %boolean for each entry in mCase.bus, entry index
                %corresponds to index in mCase.bus

			networks = {[]};
				% to track how many isolated sub-networks we have and which busses 
				% are in each

			currentNetwork = 1;
				%keep track of which network the current bus is in.



			

			%% Traverse the network %%%

			if verbose, fprintf('\n\nChecking Network for Islanding:\nTraversing the Network...\n===============================\n'); end
    
            if figures, %get the x/y limits of the figure:
                Mins = min(mCase.bus_geo);
                Maxs = max(mCase.bus_geo);
                buffer = (Maxs - Mins) * 0.1;
                Mins = Mins - buffer;
                Maxs = Maxs + buffer;
                xlim([Mins(1),Maxs(1)])
                ylim([Mins(2),Maxs(2)])
            end
            
            
			currentBus = randi(nBusses); %pick a random bus to start on (currentBus represents the index, not the ID number of a bus)
            currentBusID = mCase.bus(currentBus,1); %get the bus id associated with the current bus
            
            if figures, %draw the first node
                hold on; 
                plot(mCase.bus_geo(currentBus,1), mCase.bus_geo(currentBus,2), 'g.', 'markersize', 20);
                text(mCase.bus_geo(currentBus,1)+5, mCase.bus_geo(currentBus,2)-5, sprintf('%d',currentBusID), 'Color', 'g');
                hold off; pause(timeDelay * 6); 
            end	
			while(currentBus > 0),
                
				if visitBus(currentBus), %bus has been visited, find its network
					% check if the branch's network is different from currentNetwork
					if currentNetwork ~= busNetworks(currentBus), %different network, so merge the two
						currentNetwork = mergeNetworks(busNetworks(currentBus), currentNetwork);
					end
				else% visit the bus
					visitBus(currentBus) = true; %mark current bus as visited
					networks{currentNetwork} = [networks{currentNetwork} currentBus]; %should this eventually be busID? yes, it should be converted at the end
					busNetworks(currentBus) = currentNetwork; %mark bus's network number
					if verbose, fprintf('\t%s\n',printNetworks(networks)); end
                end

                
					
				if figures, hold on; %highlight explored node on map
					scatter(mCase.bus_geo(currentBus,1), mCase.bus_geo(currentBus,2), 'r', 'Linewidth', 2);
                    text(mCase.bus_geo(currentBus,1)+5, mCase.bus_geo(currentBus,2)-5, sprintf('%d',currentBusID), 'Color', 'r','FontWeight', 'bold');
					hold off; pause(timeDelay); 
                end





				% Traverse to next bus

				branches = mCase.branch(:,1) ==currentBusID | mCase.branch(:,2) == currentBusID;
					%get all branches connected to this bus - requires that
					%we compare the bus IDs of each branch to the bus ID of
					%the current bus

				branchIndices = find(branches & ~traversedBranch);
				if ~isempty(branchIndices), %there is atleast one untraversed branch leaving this node
					branch = randi(length(branchIndices)); %pick a random branch

					node = mCase.branch(branchIndices(branch),1:2);
					nextBusID = node(node ~=currentBusID); %gets the id of the next bus to be travelled to
					traversedBranch(branchIndices(branch)) = true; %mark branch as traversed

					if figures, %draw the branch
						hold on; 
						branch_geo = mCase.branch_geo{branchIndices(branch)};
                        for i = 1:size(branch_geo,1)-1,
                           plot(branch_geo(i:i+1,1), branch_geo(i:i+1,2), 'r', 'Linewidth',2); 
                        end
                        
                        
                        [x,y] = mplot.midpoint(branch_geo);
%                         scatter(x,y,10,'rd', 'fill')
%                         text(x+1,y-5, sprintf('%d',branchIndices(branch)), 'Color', 'r', 'FontName', 'courier');
						hold off; 	 pause(timeDelay); 
                    end	%mark traversed path;
                    
                    %move to next bus:
                    currentBus = find(mCase.bus(:,1) == nextBusID); %get the index corresponding to bus with ID of nextBusID
                    currentBusID = mCase.bus(currentBus,1);
                    
				else % all branches have been traversed, so try to find an unvisited node
					unVisited = find(~visitBus); %get all unvisited busses

					if isempty(unVisited), %all nodes have been visited
						currentBus = -1; %causes while loop to exit
					else		
						bus = randi(length(unVisited)); %pick a random index for a next bus
						currentBus = unVisited(bus); %update bus
                        currentBusID = mCase.bus(currentBus,1);
						
% 						networks{end+1} = []; %add new empty network
						networks = [networks {[]}];
						
						currentNetwork = length(networks); %set network number

						if figures, 
							hold on; 
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
                node(1) = find(mCase.bus(:,1) == node(1));%convert to indexes
                node(2) = find(mCase.bus(:,1) == node(2));
				if busNetworks(node(1)) ~= busNetworks(node(2)), %bus networks are different
					if verbose, fprintf('\n\t\tMerging networks %d and %d.\t',busNetworks(node(1)), busNetworks(node(2))); end;
					mergeNetworks(busNetworks(node(1)), busNetworks(node(2)));
                else
                    if verbose, fprintf('\n'); end
                end

% 				if verbose, fprintf('\n'); end
				if figures,
                    hold on; 
                    branch_geo = mCase.branch_geo{branchNum};
                    for br = 1:size(branch_geo,1)-1,
                        p=plot(branch_geo(br:br+1,1), branch_geo(br:br+1,2), 'b', 'Linewidth',2); 
                        set(p, 'Color',[215,103,27]/256);  
                        [x,y] = mplot.midpoint(branch_geo);
                        scatter(x,y,10,'bd', 'fill')
%                         text(x+1,y-5, sprintf('%d',branchNum), 'Color', 'b', 'FontName', 'courier');
                    end

                    hold off; 	 pause(timeDelay);
				end
			end

			numIslands = length(networks);

			oldNetworks = networks;
			if verbose,
				fprintf('\n\nSummary:\n============\n');
				fprintf('\tNumber of networks: %d\n', numIslands);
            end

            %sort networks by largest-first
			lengths = zeros(1, length(networks));
			for i = 1:length(networks), lengths(i) = length(networks{i}); end
			[~,indices] = sort(lengths, 'descend');
            
            %for each network, convert to sorted list of bus ids
			networks = networks(indices);
            for i = 1:length(networks),
                networks{i} = mCase.bus(sort(networks{i},1));
            end

			function out = printNetworks(myNetworks)
			%returns a string output of 'networks'
				out = '';
				for network = 1:length(myNetworks)
					sublist = myNetworks{network};
					sublist = sprintf('%d ', mCase.bus(sublist,1));
					out = [out, [sprintf('%d:[',network), sublist(1:end-1), ']'], '   '];
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

