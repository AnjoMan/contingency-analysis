myCase = faultCases{511};

if isa(myCase, 'cell'), 
	myCase = myCase{1};
end

myCase = runpf(myCase);

rated = myCase.branch(:,6);
P = myCase.branch(:,14);


bar(100*abs(P)./rated); ylim([0,102]);
hold on; plot([0,40], [100, 100], 'r-'); hold off;