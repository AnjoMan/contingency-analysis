a1S = [1:200000];
a2S = [150000:350000];



numTimes = 1000;
timesA = zeros(1, numTimes);
timesB = zeros(1, numTimes);

timesC = zeros(1, numTimes);

hWaitbar = waitbar(0, 'Benchmarking');
for time = 1:numTimes,
	
	a1 = a1S;
	a2 = a2S;
	
	waitbar(time/numTimes, hWaitbar);
	tic;
	
		a3 = union(a1,a2);	
	
	timesA(time) = toc;
	
	tic;
	
	a12 = sort([a1(:); a2(:)]);
	a12( find(a12( a12(1:end-1)' == a12(2:end)' ))) = [];
	
	timesB(time) = toc;
	
	tic;
	
	a1 = sort(a1);
	a2 = sort(a2);
	
	a3 = fast_union_sorted(a1,a2);
	
	
	
	
	
	timesC(time) = toc;
	
end


delete(hWaitbar);


fprintf('Builtin Union = %f\n', mean(timesA));

fprintf('My Union = %f\n', mean(timesB));
fprintf('My Union w/o fcall = %f\n', mean(timesC));

fprintf('Speedup: %.2f\n', (mean(timesA)-mean(timesB))/mean(timesA)*100);

fprintf('Speedup w/o fcall: %.2f\n', (mean(timesA)-mean(timesC))/mean(timesA)*100);