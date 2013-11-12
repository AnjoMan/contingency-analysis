function [networks] = findIslands(mCase, figures, verbose)
%findIslands   traverse a network to identify isolated busses
%
% Given a matpower case, this code explores the network's branch
% connections to identify isolated busses or groups of busses. It returns a
% cell array where each element is a collection of busses that are linked
% to a network.
%
% Usage:
%   [networks] = findIslands(mCase);
%
%   [networks] = findIslands(mCase, true); produces a plot of the network
%   showing all processed elements in red; depends on the case having Xpos
%   and Ypos values for each bus
%
%   [networks] = findIslands(mCase, true, true); steps through the network
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


	if figures && isfield(mCase, 'fault'), figure; gridPlot(rmfield(mCase,'fault')); end
	

	
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
			
		
		
		if visitBus(currentBus), %bus has been visited, find its network
			% check if the branch's network is different from currentNetwork
			if currentNetwork ~= busNetworks(currentBus), %different network, so merge the two
				currentNetwork = mergeNetworks(busNetworks(currentBus), currentNetwork);
			end
		else% visit the bus
			visitBus(currentBus) = true; %mark current bus as visited
			networks{currentNetwork}(end+1) = currentBus; %add bus to current network 
			busNetworks(currentBus) = currentNetwork; %mark bus's network number
			if verbose, fprintf('\t%s\n',printNetworks(networks)); end
		end
		
		
		if figures, hold on; scatter(mCase.Xpos(currentBus), mCase.Ypos(currentBus), 'r', 'Linewidth', 2); hold off; pause(timeDelay); end
			%highlight node on map

			
			
			
			
		% Traverse to next bus
		
		branches = mCase.branch(:,1) == currentBus | mCase.branch(:,2) == currentBus;
			%get all branches connected to this bus

		branchIndices = find(branches & ~traversedBranch);
		if ~isempty(branchIndices), %there is atleast one untraversed branch leaving this node
			branch = randi(length(branchIndices)); %pick a random branch
			node = mCase.branch(branchIndices(branch),1:2);
			nextBus = node(node ~=currentBus);
			traversedBranch(branchIndices(branch)) = true; %mark branch as traversed
			
			if figures, hold on; plot(mCase.Xpos([currentBus, nextBus]), mCase.Ypos([currentBus, nextBus]), 'r', 'Linewidth', 2); hold off; 	 pause(timeDelay); end
			 %mark traversed path;
			 
			currentBus = nextBus; %update bus.
		else % all branches have been traversed, so try to find an unvisited node
			unVisited = find(~visitBus); %get all unvisited busses
		
			if isempty(unVisited), %all nodes have been visited
				currentBus = -1; %causes while loop to exit
			else		
				bus = randi(length(unVisited)); 
				currentBus = unVisited(bus); %update bus
				networks{end+1} = []; %add new empty network
				currentNetwork = length(networks); %set network number
				
				if figures, 
					hold on; 
					plot(mCase.Xpos(currentBus), mCase.Ypos(currentBus), 'g.', 'markersize', 20); 
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
			hold on; p = plot(mCase.Xpos(node), mCase.Ypos(node), 'r', 'Linewidth', 2); 
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

		networks{newNetwork} = union(networks{newNetwork}, networks{oldNetwork});
			%unite networks on lower-numbered network
		networks = networks( 1:length(networks) ~= oldNetwork);
			%delete higher-numbered network
		for i = 1:length(networks),	busNetworks(networks{i}) = i; end
			%update bus network numberings
	
		currentNetwork = newNetwork; %update network number
		
		if verbose, fprintf('\t%s\n',printNetworks(networks)); end
	end
end

