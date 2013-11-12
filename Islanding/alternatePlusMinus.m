%this script tests the algorithm for alternating between next highest and
%lowest

nums = [];
list = [1:10, 26:30];

bus = 32;
count = 0;
while(~any(list == bus))
	bus = mod(bus + (count* (-1)^(mod(count, 2))), max(list));
	count = count+1;
	nums = [nums; bus];
	fprintf('bus: %d\n', bus);
end



plot(nums, 'o');

figure; plot(sort(nums), 'o');