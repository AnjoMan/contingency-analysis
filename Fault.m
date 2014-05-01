classdef Fault
	%FAULT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
        id = 0;
		label = '';
		branch = [];
		bus = [];
		gen = [];
		trans = [];
	end
	
	methods
		
		function fault_obj = Fault(label,args, faultNum)
			%label: text description of the object
			%args: branch{ list by index}, bus {list by index }, gen { list by index }, transformer {list
			%by index}
            if nargin > 2,
                fault_obj.id = faultNum;
            end
            
			if length(args) > 0,
				fault_obj.branch = args{1};
			end
			
			if length(args)> 1,
				fault_obj.bus = args{2};
			end
			
			if length(args)>2,
				fault_obj.gen = args{3};
			end
			
			if length(args)>3, %transformers (not transmission lines)
				fault_obj.trans = args{4};
			end
			fault_obj.label = label;
			
		end
		
		function stringRep = print(obj)
		% produce a string represntation of faults - useful for printing
		% table of faults
		
			branchS = ['[', sprintf('%d ',obj.branch), ']'];
			busS = ['[', sprintf('%d ', obj.bus), ']'];
			genS = ['[', sprintf('%d ', obj.gen), ']'];
			try transS = [ '[', sprintf('%d ', obj.trans), ']']; catch transS = ''; end 
               
			stringRep = sprintf( 'Elements: Br:%20s\tBu:%20s\tGe:%20s\tTr:%20s', branchS, busS, genS,transS);
			if nargout == 0,
				fprintf(stringRep);
			end
		end
		
		function outStruct = tostruct(obj)
			outStruct.label = obj.label;
			outStruct.branch = obj.branch;
			outStruct.bus = obj.bus;
			outStruct.gen = obj.gen;
			outStruct.trans = obj.trans;
			
		end
		
		function outList = tolist(obj)
			outList = {};
			outList{end+1} = obj.label;
			outList{end+1} = obj.branch;
			outList{end+1} = obj.bus;
			outList{end+1} = obj.gen;
			outList{end+1} = obj.trans;
        end
        
        function [branch,bus,gen,trans] = consolidate(obj,base)
            nBranches = size(base.branch,1);
			nGens = size(base.gen,1);
			nBusses = size(base.bus,1);
            
            bus = obj.bus;
            branch = obj.branch;
            gen = obj.gen;
            trans = obj.trans;
            
            
            
            
            try nTrans = length(base.trans); catch nTrans = 0; end
			
			%take care of any transformer faults
			if ~isempty(trans),
				%from all transformer faults, gather up a list of branches,
				%busses, and generators involved
				tBusses = [];
				tBranches = [];
				tGens = [];
				for transInd = obj.trans,
					tBusses = [ tBusses base.trans{transInd}{2}];
					tBranchBusses = base.trans{transInd}{1};
					%from connecting busses get branch indices
					for ind = 1:size(tBranchBusses,1),
						tBranches = [tBranches find(tBranchBusses(ind,1) == base.branch(:,1) & tBranchBusses(ind,2) == base.branch(:,2))];
						tBranches = [tBranches find(tBranchBusses(ind,2) == base.branch(:,1) & tBranchBusses(ind,1) == base.branch(:,2))];
					end
					tGens = [tGens base.trans{transInd}{3}];
				end
				
				bus = union(bus, tBusses);
				branch = union(branch, tBranches);
				gen = union(gen, tGens);
            end
            
            %take care of bus faults
			if ~isempty(obj.bus),
				markBranch = zeros(1,nBranches);
				markGen = zeros(1,nGens);
				busIndices = [];
				for bus = obj.bus(:)',%because of no 'for each in x:', you have to ensure the orientation of array
					for branch = 1:nBranches %mark branch if it connects to a node with id of bus
						markBranch(branch) =  markBranch(branch) || ismember(base.bus(bus,1), base.branch(branch, 1:2));
					end
					for gen = 1:nGens
						markGen(gen) = markGen(gen) || ismember(base.bus(bus,1), base.gen(gen,1));
					end

					
				end
				gen = union(gen, find(markGen));
				%faultCase.bus = base.bus( setdiff(1:nBusses, busIndices),:);
				branch = union( branch, find(markBranch));
            end
            
            
        end
        
        
		function faultCases = applyto(obj,base)
			faultCase = base;
			nBranches = size(base.branch,1);
			nGens = size(base.gen,1);
			nBusses = size(base.bus,1);
            try nTrans = length(base.trans); catch nTrans = 0; end
			
% 			%take care of any transformer faults
% 			if ~isempty(obj.trans),
% 				%from all transformer faults, gather up a list of branches,
% 				%busses, and generators involved
% 				tBusses = [];
% 				tBranches = [];
% 				tGens = [];
% 				for transInd = obj.trans,
% 					tBusses = [ tBusses base.trans{transInd}{2}];
% 					tBranchBusses = base.trans{transInd}{1};
% 					%from connecting busses get branch indices
% 					for ind = 1:size(tBranchBusses,1),
% 						tBranches = [tBranches find(tBranchBusses(ind,1) == base.branch(:,1) & tBranchBusses(ind,2) == base.branch(:,2))];
% 						tBranches = [tBranches find(tBranchBusses(ind,2) == base.branch(:,1) & tBranchBusses(ind,1) == base.branch(:,2))];
% 					end
% 					tGens = [tGens base.trans{transInd}{3}];
% 				end
% 				
% 				obj.bus = union(obj.bus, tBusses);
% 				obj.branch = union(obj.branch, tBranches);
% 				obj.gen = union(obj.gen, tGens);
% 			end
% 			
% 			
% 			
% 			
% 			%take care of bus faults
% 			if ~isempty(obj.bus),
% 				markBranch = zeros(1,nBranches);
% 				markGen = zeros(1,nGens);
% 				busIndices = [];
% 				for bus = obj.bus(:)',%because of no 'for each in x:', you have to ensure the orientation of array
% 					for branch = 1:nBranches %mark branch if it connects to a node with id of bus
% 						markBranch(branch) =  markBranch(branch) || ismember(base.bus(bus,1), base.branch(branch, 1:2));
% 					end
% 					for gen = 1:nGens
% 						markGen(gen) = markGen(gen) || ismember(base.bus(bus,1), base.gen(gen,1));
% 					end
% 
% 					
% 				end
% 				obj.gen = union(obj.gen, find(markGen));
% 				faultCase.bus = base.bus( setdiff(1:nBusses, busIndices),:);
% 				obj.branch = union( obj.branch, find(markBranch));
% 			end
% 			
            [mBranch, mBus, mGen, mTrans] = obj.consolidate(base);
            
            %remove busses from faultCase
            if ~isempty(mBus)
                faultCase.bus = base.bus( setdiff(1:nBusses, mBus),:);
            end
            
            
            
            
            
            
            
			%take care of any generator faults
			if ~isempty(mGen),
				faultCase.gen = base.gen( setdiff(1:nGens, mGen),:);
				faultCase.gencost = base.gencost( setdiff( 1:nGens, mGen),:);
			end

			%take care of branches
			if ~isempty(mBranch) ,
				faultCase.branch = base.branch( setdiff( 1:nBranches, mBranch),:);
				try faultCase.branch_geo = base.branch_geo( setdiff( 1:nBranches, mBranch)); catch end
			end
			
			networks = island.find(faultCase,true,true); %get island groups
			if length(networks)>1,
				faultCases = island.resolve(faultCase, networks);
			else
				faultCases = {faultCase};
			end
		end
	end

end
