function [CPFloads, messages, faults, base, baseLoad] = cpf_compare(base)

% 	base = loadcase('case30_mod.mat');
	
	
	baseCPF = cpf(base);
	baseLambda = baseCPF.max_lambda;
	
	baseLoad = getLoad(base, baseLambda);

% 	profile on
	faults = defineFaults(base);
%     profile viewer
	nFaults = length(faults);
	ppm = ParforProgMon('Running CPF on Faults: ', nFaults, floor(nFaults/100));

	CPFloads = zeros(1, nFaults);
	messages = [];
    msg = [];
	
%     for faultNum = 1:length(faults),
% 	parfor faultNum = 1:length(faults),
	for faultNum = 42,
		fprintf('Fault %d of %d\n', faultNum, nFaults);
		ppm.update(faultNum);
		
		try
			[CPFloads(faultNum), msg] = faultCPF(base, faults{faultNum});
		catch err
			rethrow(addCause(err, MException('CPF:CPFfault', sprintf('Error faulting case %d', faultNum))));			
		end
		messages = [messages msg];
	end
	
	mprint.printMessages(messages);
	pause(0.2); ppm.delete();
end

function [load, messages, results] = faultCPF(base,fault)
    
	fprintf('\tFaulting Case\n');
	myCase = fault.applyto(base);

	lambda = [];
	messages = [];
	sigmaForLambda =5;
	sigmaForVoltage = 0.025;
	
	fprintf('\tRunning CPF\n');
	results = [];
	loads = zeros(1, length(myCase));
    nIslands = length(myCase);
	for i = 1:nIslands,
		if length(myCase) > 1, fprintf('\t\tSubcase %d\n', i); end
		
		%case where loads are isolated and have to be shed
		if size(myCase{i}.gen,1) == 0, 
			messages = addMessage( messages, newMessage('No Generators'));
			loads(i) = 0; 
			continue;
		elseif nnz(myCase{i}.bus(:,3)) == 0,
			messages = addMessage(messages, newMessage('No loads'));
			loads(i) = 0;
			continue;
		end
		
		if size(myCase{i}.bus,1) == 1,
			loads(i) = 0;
			continue;
		end
		try
			myCPFresults = cpf(myCase{i}, -1, sigmaForLambda, sigmaForVoltage, false);
			if isnan(myCPFresults.max_lambda), 
				myCPFresults.max_lambda = 0; 
				messages= addMessage(messages, newMessage('CPF failed', false));
			else
				if i>1, 
					messages = addMessage(messages, newMessage('CPF succeeded on island'));
				end
			end
			
			loads(i) = getLoad(myCase{i}, myCPFresults.max_lambda);
		catch
			keyboard;
		end
	
		lambda = [lambda myCPFresults.max_lambda];
		results = [results myCPFresults];
		
	end
	
	
% 	lambda = mean(lambda);
	load = sum(loads);
	
	function message = newMessage(text, success)
		if nargin<2, success = true; end

		message.text = text;
		message.faultNum =fault.id;
		message.faults = fault.print();
		message.islandNum = sprintf('%d / %d',i, nIslands);
		message.success = success;

	end
	
	function messages = addMessage(messages, message)
		messages = [messages message];
	end
end

function load = getLoad(myCase, lambda)

	PD = myCase.bus(:,3);
	participation = PD ./sum(PD);
	power = PD .* (participation == 0) + participation * lambda * myCase.baseMVA;
	load = sum(power);

end



