close all;

%% Base Case
%this is case30 with positions added for graphing
% base = loadcase('case118mod.mat');
% base = loadcase('baseCase.mat');
base = loadcase('case30_updated.mat');


nBusses = length(base.bus(:,1));


connections = base.branch(:,1:2);
ijLinks = [ nBusses * (connections(:,2)-1) + connections(:,1);...
			nBusses * (connections(:,1)-1) + connections(:,2)];

connXY = zeros(nBusses, nBusses);
connXY(ijLinks) = 1;
% 
% 
% 
% conns = [connections(:,1); connections(:,2)];
% 
% [N,B] = hist(conns,1:nBusses);
% 
% [N,I] = sort(N, 'descend')
% B = B(I);
% 
% radii = 1./N;
% angle = linspace(0,4*pi, nBusses);
% [X,Y] = pol2cart(angle, radii);
% X = randn(1, nBusses)'*30;
% Y = randn(1, nBusses)'*30;
% 
% X = base.Xpos;
% Y = base.Ypos;
% gplot(connXY, [X,Y], 'o-');
% 
% figure;
% 
% scatter(X,Y);
% hold on; 
% %for each bus, find a better location based on adjacent busses
% for i = 1:nBusses,
% 	[X(i), Y(i)] = optimalLocation(i, X,Y, connections);
% 
% 	scatter(X(i),Y(i), 'r');
% % 	pause(0.01);
% 	
% 	
% end
% hold off;

X = base.Xpos;
Y = base.Ypos;
figure; 

I = imread('layout_30bus.png');
hi = imagesc(I);
mCase = base; mCase.Xpos = X; mCase.Ypos = Y;
hold on; gridPlot(mCase); hold off;


x = mean(X);
y = mean(Y);





while (sum(x>xlim) == 1 && sum(y>ylim) == 1)
	
	[x,y] = getpts
	x = x(1);
	y = y(1);
	
	dist = zeros(1,length(X));
	for i = 1:length(dist),
		dist(i) = sqrt( (x-X(i)).^2) + sqrt( (y-Y(i)).^2);
	end
	[~, minDex] = min(dist)

% 	[X(minDex), Y(minDex)] = optimalLocation(minDex, X, Y, connections);

	[x,y] = getpts
	x = x(1);
	y = y(1);
	
	if ~(sum(x>xlim) == 1 && sum(y>ylim) == 1)
		break;
	end
	X(minDex)=x;
	Y(minDex) = y;

	Xlim = xlim;
	Ylim = ylim;
% 	I = imread('layout_118bus.png');
	hi = imagesc(I);
	mCase = base; mCase.Xpos = X; mCase.Ypos = Y;
	hold on; gridPlot(mCase); hold off;
	xlim(Xlim);
	ylim(Ylim);
end


base.Xpos = X;
base.Ypos = Y;