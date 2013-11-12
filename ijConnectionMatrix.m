connections = [1 2; 1 4; 3,4];


nBusses = 4;

connXY = zeros(nBusses, nBusses);

for i=1:length(connections),
	
	connXY( connections(i,1), connections(i,2)) = 1;
	connXY( connections(i,2), connections(i,1)) = 1;
end





indices = [ nBusses * (connections(:,2)-1) + connections(:,1);...
			nBusses * (connections(:,1)-1) + connections(:,2)];
connXY2 = zeros(nBusses, nBusses);

connXY2(indices) = 1;