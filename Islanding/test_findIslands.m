load CPFcases.mat;

runTimes = 1000;
numCases = length(CPFcases);
times =zeros(1,runTimes);
hWaitbar = waitbar(0, 'Testing for islands on all cases');


for i = 1:runTimes,
	waitbar(i/runTimes, hWaitbar);
	
	caseNum = randi(numCases);
	
	mCase = CPFcases(caseNum);
	tic;
	result = findIslands(mCase, false, false);
	times(i) = toc;
end

pause(0.2); delete(hWaitbar);

fprintf('Mean completion time:\t %d\n', mean(times));
fprintf('STD: %d\n', std(times));
