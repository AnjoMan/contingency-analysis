
clear all;


array = randi(200, 1, 10000);
arrayG = gpuArray(array);
numTimes = 400;
timesA = zeros(1,numTimes);
timesB = timesA;


for i = 1:numTimes,
	
% 	myCellA = myCell;
% 	myCellB = myCellA;
	
	tic;
	
		sort(array);
		
	timesA(i) = toc;
	
	
	
	tic
	
		sort(arrayG);
		
	timesB(i) = toc;
	
	
end


fprintf('A:\t%f\n', mean(timesA));

fprintf('B:\t%f\n', mean(timesB));

		









