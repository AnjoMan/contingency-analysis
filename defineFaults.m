function faults = defineFaults(base)
	if nargin == 0,
		base = loadcase('case30_mod.mat');
	end
% 	base = loadcase('case30_mod.mat');


	nBranches = size(base.branch,1);
	nBusses = size(base.bus,1);
	nGens = size(base.gen,1);
	nTrans = size(base.trans,2);



% 	singleBranchFaults = 1:nBranches;
% 	singleBranchFaults = [1,2,3,4,5];
% 	singleBranchFaults = [1,2,8,18,30];
	singleBranchFaults = [1,2,18];


	singleBusFaults = 1:nBusses;
% 	singleBusFaults = [1,3,5,7,8];
% 	singleBusFaults = [1,2,8,15,20];	
% 	singleBusFaults = [15]; 


% 	singleGenFaults = 1:nGens;
	singleGenFaults = [1];
	
% 	singleTransFaults = 1:nTrans;
	singleTransFaults = [1];
	
	if ~exist('singleBranchFaults', 'var'), singleBranchFaults = []; end
	if ~exist('singleBusFaults', 'var'), singleBusFaults = []; end
	if ~exist('singleGenFaults', 'var'), singleGenFaults = []; end
	if ~exist('singleTransFaults', 'var'), singleTransFaults = []; end
	
% 	[faults, columns] = combineFaults(2, singleBranchFaults, singleBusFaults, singleGenFaults);
	[faults, columns] = combineFaults(6, singleBranchFaults, singleBusFaults, singleGenFaults, singleTransFaults);
	singleFaults = [];
	for i = 1:length(faults)
		fault = faults{i};
		
		if length(fault.branch) + length(fault.bus) + length(fault.gen) + length(fault.trans) == 1,
			singleFaults = [singleFaults fault]
		end
	end
		
	fprintf('%30s\t', columns{1})
	for i = 2:length(columns),
		fprintf('%20s\t', columns{i});
	end
	fprintf('\n');
	
% 	for i = 1:length(faults),
% 		
% 		faults{i}.print();
% 	end
end



function [faults, columns] = combineFaults(level,varargin)
	
	elements = {'branch', 'bus', 'generator', 'transformer'};
	
	%getting boundaries for  x = [ varargin{1}, varargin{2}, varargin{3}]
	
	i = 1;
	while i<= length(varargin),
		if isempty(varargin{i}),
			varargin = varargin( 1:end ~= i);
			elements = elements(1:end ~= i);
		else
			i = i+1;
		end
		
	end
	lengths = zeros(length(varargin),1);
	for i = 1:length(varargin)
		lengths(i) = length(varargin{i});
	end
	lengths = cumsum(lengths);
	
	ranges = [1+[0; lengths(1:end-1)] [lengths] ];
	offset = [0; ranges(1:end-1, 2)];
	
	indices = ranges(1,1):ranges(end,2);
	columns = ['label', elements];
	function groups = grouping(indices)
	% returns grouping in varargin of each index specified in 'indices'
		groups = zeros(length(indices), 1);
		for index = 1:length(indices),
			groups(index) = max(find(sum(indices(index) < ranges,2) <= 1));
		end
	end

	function [gIndices, mGroups] = groupIndex(indices)
	% converts indices of x = [ varargin{1}, varargin{2}, varargin{3}]
	% to indices of lists in varargin, accompanied by grouping number
		mGroups = grouping(indices);
		
		gIndices = zeros(length(indices),1);
		for index = 1:length(indices)
% 			gIndices(index) = varargin{mGroups(index)}(indices(index) - offset(mGroups(index)));
			gIndices(index) = indices(index) - offset(mGroups(index));
		end
	end



% 	faults = cell(1,1);
	faults = {};
	
	for l = 1:level,

		combos = nchoosek(indices, l);		
		for combo = combos',
			
			
			[gIndices, mGroups] = groupIndex(combo);
			if l <= 1, label = sprintf('single %s fault', elements{mGroups});
			else label = 'combined fault';
			end
	% 		label = '';
	% 		for str = elements(mGroups)
	% 			label = sprintf('%s, %s', label, str{1});
	% 		end
	% 		label = sprintf('combined %s fault', label(3:end));
	
			arguments = cell(length(varargin),1);
			for el = 1:length(gIndices),
				arguments{mGroups(el)}(end+1) = varargin{mGroups(el)}(gIndices(el));
			end
			faults{end+1} = Fault(label, arguments);
% 			faults{end}.print()		
		end
	end
end