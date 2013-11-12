close all;

%% Base Case
%this is case30 with positions added for graphing
% base = loadcase('case118mod.mat');
base = loadcase('case30_updated.mat');

% 
% X = base.Xpos;
% Y = base.Ypos;
% figure; 
% 
% I = imread('layout_30bus.png');
% hi = imagesc(I);
% mCase = base; mCase.Xpos = X; mCase.Ypos = Y;
% hold on; gridPlot(mCase); hold off;
% 
% 
% x = mean(X);
% y = mean(Y);
% 
% 
% nBranches = length( base.branch(:,1));
% connections = base.branch(:,1:2);
% 
% % branchPoints = cell(1, nBranches);
% 
% for i = 25,
% 	
% 	busses = connections(i,:);
% 	
% 	X(busses);
% 	Y(busses);
% 	hold on
% 	plot(X(busses), Y(busses), 'r');
% 	scatter(X(busses(1)), Y(busses(1)), 'g');
% 	Xlims = xlim;
% 	Ylims = ylim;
% 	
% 	
% 	line = [X(busses(1)) Y(busses(1))]
% 	
% 	endPoint = [X(busses(2)), Y(busses(2))];
% 	[x,y] = ginput(1)
% 	
% 	
% 	while sum(x<Xlims) == 1 && sum(y<Ylims) == 1,
% 		
% 		endDistance = sqrt(sum(([x,y] - endPoint).^2))
% 		nPoints = size(line,1);
% 		
% 		if endDistance >5,
% 			line = [line; [x,y]];
% 		
% 			plot( line(nPoints:nPoints+1,1), line(nPoints:nPoints+1,2), 'r');
% 			scatter(line(end,1),line(end,2), 'g'); %plot new point
% 		
% 			[x,y] = ginput(1);
% 		else
% 			line = [line; endPoint];
% 			
% 			plot( line(nPoints:nPoints+1,1), line(nPoints:nPoints+1,2), 'r');
% 			scatter(line(end,1),line(end,2), 'g'); %plot new point
% 			break;
% 		end
% 			
% 		
% 	end
% 	
% 	branchPoints{i} = line;
% 	
% 	fprintf('finished %d of %d\n\n', i, nBranches);
% 	close all;
% 	
% 	hi = imagesc(I);
% 	mCase = base; mCase.Xpos = X; mCase.Ypos = Y;
% 	hold on; gridPlot(mCase); hold off;
% 
% 	base.line{i} = line;
% 	pause(0.5)
% 	
% 	
% end
% 
% hold off
figure; hold on
for i = 1:length(base.branch_geo),
	
	branch_geo = base.branch_geo{i}
	
	for j = 1:length(branch_geo)-1,
		plot(branch_geo(j:j+1, 1), branch_geo(j:j+1,2));
	end
	
	scatter(branch_geo([1,end], 1), branch_geo([1,end],2));
	
end
