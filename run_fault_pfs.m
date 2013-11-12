base = loadcase('baseCase.mat');


baseResults = runpf(base);


[nBranches, categories] = size(base.branch);

%Define which branches are faulted.
singleFaults = 1:nBranches;
doubleFaults = nchoosek(singleFaults, 2);
tripleFaults = nchoosek(singleFaults, 3);

nSingles = length(singleFaults);
nDoubles = length(doubleFaults);
nTriples = length(tripleFaults);
nCases = nSingles + nDoubles + nTriples;

%% Build A List of fault cases
hProgress = waitbar(0, 'Building set of faulted cases');
for i = 1:nBranches,
	waitbar(1/nCases, hProgress);
	
	singleFaultCases{i} = branchFault(base, i);
end
doubleFaultCases ={};

for i = 1:length(doubleFaults),
	waitbar((nSingles + i)/nCases, hProgress);
	doubleFaultCases{i} = branchFault(base, doubleFaults(i,:));
end
tripleFaultCases = {};
for i = 1:length(tripleFaults),
	waitbar( (nSingles + nDoubles + i)/nCases, hProgress);
	tripleFaultCases{i} = branchFault(base, tripleFaults(i,:));
end

pause(0.2); delete(hProgress);


faultCases = [singleFaultCases, doubleFaultCases, tripleFaultCases];

%% Solve Each case to identify contingencies
hProgress = waitbar(0, 'Checking contingencies for fault conditions');
numCalcs = length(faultCases);

solves = false(1,numCalcs);
error = false(1,numCalcs);

faultCaseResults = cell(1,length(faultCases));
for i = 1:length(faultCases),
	waitbar(i / numCalcs, hProgress);
	
	if isa(faultCases{i}, 'cell'),
		thisCase = faultCases{i}{1};
	else
		thisCase = faultCases{i};
	end
	
	try
		thisCaseResults = runpf(thisCase);
		solves(i) = thisCaseResults.success;
		faultCaseResults{i} = thisCaseResults;
	catch
		solves(i) = false;
		error(i) = true;
	end
	
	
end

pause(0.5); delete(hProgress);

branchLimitExceeded = false(1, length(faultCaseResults));
for i = 1:length(faultCaseResults)
	
	thisCase = faultCaseResults{i};
	
	rated = thisCase.branch(:,6);
	P = thisCase.branch(:,14);
	
	branchLimitExceeded(i) = any( abs(P) ./rated >= 1);
	
end

branchViolations = faultCaseResults(branchLimitExceeded);
% %% Run CPF on each fault case
% CPFcases = faultCases(solves == false);
% 
% hProgress = waitbar(0,'Running CPF on each contingency');
% 
% for i = 1:length(CPFcases)
% 	waitbar(i/length(CPFcases), hProgress);
% 	CPFresults(i) = cpf(CPFcases(i), -1, 0.2, 0.05);
% end
% 
% 
% pause(0.5); delete(hProgress);

