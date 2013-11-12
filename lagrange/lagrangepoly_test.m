repeat = 100;

times = zeros(1, repeat);


	xs = 1:25;
	ys = [xs.^2];
	
solutions = zeros(2,repeat);
for i = 1:repeat
	x = randi([26,40]);
	
	tic;
	solutions(:,i) = lagrangepoly(x, xs, ys);
	times(i) = toc;
end

	
	

	