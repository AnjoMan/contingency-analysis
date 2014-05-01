function base = gridGraph()

    close all;

    %% Base Case
    %this is case30 with positions added for graphing
    % base = loadcase('case118mod.mat');
    % base = loadcase('baseCase.mat');
    base = loadcase('case118_updated.mat');


    nBusses = length(base.bus(:,1));


    connections = base.branch(:,1:2);
    ijLinks = [ nBusses * (connections(:,2)-1) + connections(:,1);...
                nBusses * (connections(:,1)-1) + connections(:,2)];

    connXY = zeros(nBusses, nBusses);
    connXY(ijLinks) = 1;


    X = base.bus_geo(:,1);
    Y = base.bus_geo(:,2);
    

%     X = X-min(X);
%     Y = Y-min(Y);
% 
%     X = X/max(X) * 1100 + 50;
%     Y = Y/max(Y) * 700 + 50;
%     Y = Y + 800;
    figure; 

    I = imread('ieee118.png');
    hi = imagesc(I);
    mCase = base; mCase.Xpos = X; mCase.Ypos = Y;
    % hold on; gridPlot(mCase); hold off;

    gridDraw(X,Y,connections, I);
    x = mean(X);
    y = mean(Y);





    while (sum(x>xlim) == 1 && sum(y>ylim) == 1)
    
        % click near the point you want to pick
        [x,y] = ginput(1);
        x = x(1);
        y = y(1);
        
        if ~(sum(x>xlim) == 1 && sum(y>ylim) == 1)
            break;
        end
        
        dist = zeros(1,length(X));
        for i = 1:length(dist),
            dist(i) = sqrt( (x-X(i)).^2) + sqrt( (y-Y(i)).^2);
        end
        [~, minDex] = min(dist);
        
        %put a dot on the selected bus
        hold on; plot(X(minDex),Y(minDex), 'g.'); hold off;
    % 	[X(minDex), Y(minDex)] = optimalLocation(minDex, X, Y, connections);

        %pick a new location for the point
        [x,y] = ginput(1);
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
        gridDraw(X,Y,connections,I);
        xlim(Xlim);
        ylim(Ylim);
    end

    close all
    base.bus_geo = [X,Y];
    savecase('case118_updated.mat',  base);
   
end

function gridDraw(X,Y, connections, image)

    if nargin > 3,
        imagesc(image);
    else
        figure;
    end
    
    hold on;
    scatter(X,Y, 'k');
    for i = 1:size(connections,1)
        con = connections(i,:);
        
        plot(X(con), Y(con), 'k')
    end
    
    hold off;
    

end