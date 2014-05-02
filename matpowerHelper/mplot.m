classdef mplot
	%PRINT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
	end
	
	methods
	end
	methods(Static)
        function plot(system)
            figure; hold on; set(gca,'YDir','reverse');
            
            %plot branches
            for branchNum = 1:length(system.branch_geo)
               branch = system.branch_geo{branchNum};
               
               for node = 1:size(branch,1)-1
                  plot( branch(node:node+1,1), branch(node:node+1,2),'k'); 
               end
               
               %label branches
               [x,y] = mplot.midpoint(branch);
               scatter(x,y,10,'kd', 'fill')
               text(x+1,y-5, sprintf('%d',branchNum), 'Color', 'k', 'FontName', 'courier');
            end
            
            %plot busses
            scatter(system.bus_geo(:,1),system.bus_geo(:,2), 'b', 'fill')
            
            %label busses
            for i = 1:length(system.bus_geo),               
               text( system.bus_geo(i,1)+1, system.bus_geo(i,2)-5, sprintf('%d',i), 'Color', 'b', 'FontWeight', 'bold'); 
            end
            hold off;
           
       
        end
        
        
        function [x,y] = midpoint(branch_geo)
            distances =[0; sqrt(sum((branch_geo(2:end,:) - branch_geo(1:end-1,:)).^2,2))]; %find distance between points
            cs = cumsum(distances);

            ltHalf = find(diff(cs < sum(distances)/2)); %find the first point in the segment containing the midpoint

            pctAlong = ( sum(distances)/2 - cs(ltHalf) ) / distances(ltHalf+1);
            point = branch_geo(ltHalf,:) + pctAlong * (branch_geo(ltHalf+1,:) - branch_geo(ltHalf,:));

            
            x = point(1);
            y = point(2);
        
        end
        
        function faulted(system, fault)
            
            [mBranch,mBus,~,~] = fault.consolidate(system);
            mplot.plot(system);
            
            hold on;
%             transBranches = [];
%             for trans = fault.trans
%                 transformer = system.trans{trans};
%                 transBranches = [transBranches transformer{1}];
%             end
%             
%             transBusses = [];
%             for trans = fault.trans
%                 transformer = system.trans{trans};
%                 transBusses = [transBusses transformer{2}];
%             end
                
%             branches = [branch transBranches];
%             busses = [bus transBusses];
            
            
            
            for br = mBranch(:)',
               branchGeo = system.branch_geo{br};
               for node = 1:size(branchGeo,1)-1
                  plot(branchGeo(node:node+1,1), branchGeo(node:node+1,2), 'r');
               end
               
               %label branches
               [x,y] = mplot.midpoint(branchGeo);
               scatter(x,y,10,'rd', 'fill')
               text(x+1,y-5, sprintf('%d',br), 'Color', 'r');
            end
            
            scatter(system.bus_geo(mBus,1), system.bus_geo(mBus,2),'r', 'fill');
            %label busses
            for bu = mBus(:)',               
               text( system.bus_geo(bu,1)+1, system.bus_geo(bu,2)-5, sprintf('%d',bu), 'Color', 'r', 'FontWeight', 'bold'); 
            end
            
            
            
            
            
            
        end
	end
	
end

