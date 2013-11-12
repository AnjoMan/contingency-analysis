clear all; close all;
clc;

x = [5]

xs = 1:4
ys = [xs.^2; xs.^3]

nSamples = length(xs);

xxm = x-xs;


js = 1:nSamples;

Lj = zeros(nSamples,1);
for j = 1:nSamples,
	Lj(j) = prod(xxm(:,js~=j),2) ./  prod( xs(j)- xs(:, js~=j));
	
	
end

Lx = ys * Lj;



plot(ys', 'o-'); hold on; scatter([x,x], Lx, 'r'); hold off;