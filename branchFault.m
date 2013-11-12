function [faultCase] = branchFault(base, branchesToFault, busX,busY)
% branchFault fault a branch in case
%
% This introduces a branch fault in the given case 'base' at the branches
% listed in branchesToFault.
%
% Usage:
%
% [Inputs]
%	base: case on which to work
%	branchesToFault: indices of branches to be faulted
%	(Optional)
%	  busX,busY: x,y coordinates of bus for graphing purposes.
	faultCase = base;
	[nbranchesToFault, ~] = size(faultCase.branch);
	faultCase.branch = faultCase.branch( setdiff(1:nbranchesToFault, branchesToFault), :);
	faultCase.fault = base.branch(branchesToFault,:);
	

	if nargin > 3, %bus positions are given, so gplot the busses
		connections = faultCase.branch(:,1:2);
		
		nBusses = length(busX);
		%linearize indicese where i/j th bus are connected by a branch
		ijLinks = [ nBusses * (connections(:,2)-1) + connections(:,1);...
					nBusses * (connections(:,1)-1) + connections(:,2)];

		connXY = zeros(nBusses, nBusses); connXY(ijLinks) = 1;
		
		gplot(connXY, [busX(:), busY(:)] ,'o-')
		hold on;
		for i = 1:length(branchesToFault),
			brokenBranch = base.branch(branchesToFault(i), 1:2);
			breakX = busX(brokenBranch);
			breakY = busY(brokenBranch);
			plot(breakX, breakY, 'r--');
		end
		hold off;
	end
	
			% check for islanding
	networks = island.find(faultCase); %get island groups
	if length(networks)>1,
		faultCase = island.resolve(faultCase, networks);
	else
		faultCase = {faultCase};
	end
		

end

