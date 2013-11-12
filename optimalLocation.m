function [xnew, ynew] = optimalLocation(bus, X,Y, connections)

	myBusses = connections(connections(:,1) == bus | connections(:,2) == bus, :);
	myBusses(myBusses == bus) = 0;
	myBusses = myBusses(:,1) + myBusses(:,2);
	
	
	


	xnew = ones(1,length(X(myBusses)))*X(myBusses)/length(X(myBusses));
	ynew = ones(1,length(Y(myBusses)))*Y(myBusses)/length(Y(myBusses));

%hold on; scatter(xmin, ymin, 'r'); hold off;