function [CPFlambdas, faults, base] = cpf_compare2(base)

% 	base = loadcase('baseCase.mat');

	[nBranches, ~] = size(base.branch);

	singleFaults = (1:nBranches);
	doubleFaults = nchoosek(singleFaults, 2)';

	%get a single list of faults
	faults = [num2cell(singleFaults), num2cell(doubleFaults, [1,size(doubleFaults,2)])];

	
	nFaults = length(faults);
	ppm = ParforProgMon('Running CPF on Faults: ', nFaults, floor(nFaults/100));

	CPFlambdas = zeros(1, nFaults);
	parfor i = 1:400,
		fprintf('Fault %d of %d\n', i, nFaults);
		ppm.update(i);
		CPFlambdas(i) = faultCPF(base, faults{i});
	end
	
	pause(0.2); ppm.delete();
end


function lambda = faultCPF(myCase, faults)

	fprintf('\tFaulting Case\n');
	myCase = branchFault(myCase, faults);
	
	lambda = [];
	
	fprintf('\tRunning CPF\n');
	for i = 1:length(myCase),
		if length(myCase) > 1, fprintf('\t\tSubcase %d\n', i); end
		if size(myCase{i}.bus,1) == 1,
			continue;
		end
		try
			myCPFresults = cpf(myCase{i});
		catch
			keyboard
		end
	
		lambda = [lambda myCPFresults.max_lambda];
	end
	lambda = mean(lambda);
end
