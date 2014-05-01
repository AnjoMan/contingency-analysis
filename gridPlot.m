function gridPlot(base, busX, busY, faults)
%given a case with X,Y positions for busses, creates a graph of 
	
	if isfield(base, 'fault') && nargin<4,
		faults = base.fault(:,1:2);
	end
	if isfield(base, 'Xpos') && isfield(base, 'Ypos'),
		if nargin<2,
			busX = base.bus_geo(:,1);
			busY = base.bus_geo(:,2);
		else
			if length(busX) ~= length(base.bus(:,1)) && length(busY) ~= length(base.bus(:,1)),
				busX = base.bus_geo(:,1);
                busY = base.bus_geo(:,2);
			end
		
		end
	elseif nargin<2,
		fprintf('\tgridPlot - [Error] No positions given.\n');
	end
			
		
		

	nBusses = length(base.bus(:,1));
	connections=base.branch(:,1:2);
% 	
% 	nBusses = length(busX);
% 	%linearize indicese where i/j th bus are connected by a branch
% 	ijLinks = [ nBusses * (connections(:,2)-1) + connections(:,1);...
% 				nBusses * (connections(:,1)-1) + connections(:,2)];
% 
% 	connXY = zeros(nBusses, nBusses); connXY(ijLinks) = 1;
% 
% 	gplot(connXY, [busX(:), busY(:)] ,'o-')
	hold on;
	for i = 1:nBusses,
		scatter(busX(i), busY(i), 'b');
		text(busX(i) + 2, busY(i)+2, sprintf('%d',base.bus(i,1)), 'color', 'r');
	end

	
	[numConnections, ~]= size(connections);
	busList = base.bus(:,1);
	for i = 1:numConnections,
		busA = connections(i,1); busB = connections(i,2);
		
		plot([busX(busList == busA), busX(busList == busB)], [busY(busList == busA), busY(busList == busB)]);
	end
	
	
	
	if exist('faults', 'var'), %plot faults
		[numFaults, ~] = size(faults);
		for i = 1:numFaults
			brokenBranchInds = [find( faults(i,1) == busList), find( faults(i,2) == busList)];
			breakX=busX(brokenBranchInds);
			breakY=busY(brokenBranchInds);
			plot(breakX,breakY,'r--');
		end
	end
	hold off;
end