classdef mprint
	%PRINT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
	end
	
	methods
	end
	methods(Static)
		function bus(mpc)
			nms = {'bus #', 'bus type', 'Pd', 'Qd', 'Gs', 'Bs', 'area', '|V|',...
					 '<V', 'base KV', 'zone', 'maxVm', 'minVm'};
			if isa(mpc, 'double'), mpc.bus = mpc; end
			mprint.printElement(nms, mpc.bus)
		end
		
		function gen(mpc)
			nms = {'bus #', 'Pg', 'Qg', 'Qmax', 'Qmin', 'Vg', 'mBase', 'status',...
					 'Pmax', 'Pmin', 'Pc1', 'Pc2', 'Qc1min', 'Qc1max', 'Qc2min', ...
					 'Qc2max', 'rr AGC', 'rr10', 'rr30', 'rr react', 'APF' };
			if isa(mpc, 'double'), mpc.gen = mpc; end
			mprint.printElement(nms, mpc.gen);
		end
		
		function branch(mpc)
			nms = {'index','from', 'to', 'R', 'X', 'b', 'rateA', 'rateB', 'rateC',...
				   'ratio', 'angle', 'status', 'min ang', 'max ang', ...
				   'Pinj from', 'Qinj from', 'Pinj to', 'Qinj to'};
			mprint.printElement(nms, [ (1:size(mpc.branch,1))', mpc.branch]);
		end
		
		function printElement(names, data)
			fprintf('%5s', '');
			for i= 1:length(names),
				fprintf(' %-9s|', names{i});
			end
			fprintf('\n');
			[rows, cols] = size(data);

			for i=1:rows
				
				fprintf('\t ');
				fprintf('%10.4f|', data(i,:));
				fprintf('\n');
			end
			
		end
		
		
		function loading(mpc)
			
			
		end
		
		function printMessages(messages, printSuccesses)
			if nargin<2, printSuccesses = false; end
			
			fprintf('\n\nPrinting Summary:\n\n');
			
			nNoLoads = 0;
			nCPFfails = 0;
			nNoGens = 0;
			nCPFpass = 0;
			
			for i = 1:length(messages),
				message = messages(i);
				
				if strcmp(message.text, 'No loads'), nNoLoads = nNoLoads+1; end
				if strcmp(message.text, 'CPF failed'), 
					nCPFfails = nCPFfails+1; end
				if strcmp(message.text, 'No Generators'), nNoGens = nNoGens+1; end
				if strcmp(message.text, 'CPF succeeded on island'), nCPFpass = nCPFpass+1; end
				
				
				if ~message.success || printSuccesses,
					fprintf('\tFault %d; Branches %s\n', message.faultNum, sprintf('%d ', message.faults));
					fprintf('\t\t island %2d, success: %s: %s\n\n', message.islandNum,mprint.ternary(message.success, 'true', 'false'), message.text);
				end
			end
			
			fprintf('\n')
			fprintf('# No-Load:\t\t%d\n', nNoLoads);
			fprintf('# No-Gens:\t\t%d\n', nNoGens);
			fprintf('# CPF fails:\t%d\n', nCPFfails);
			fprintf('# CPF on island:\t%d\n', nCPFpass);
			fprintf('Done.\n\n');
			
		end
		
		function a = ternary( condition, a, b)
			if ~condition, a = b; end
		end
	end
	
end

