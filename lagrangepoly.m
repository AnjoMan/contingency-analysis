function   Lx = lagrangepoly(x, xs, ys)

	nSamples = length(xs);

	xxm = x-xs;


	js = 1:nSamples;

	Lj = zeros(nSamples,1);
	for j = 1:nSamples,
		Lj(j) = prod(xxm(:,js~=j),2) ./  prod( xs(j)- xs(:, js~=j));


	end

	Lx = ys * Lj;

end
% 
% function  y = lagrangepoly(x, xs, ys)
% 
% 	ls  = zeros(1, length(xs));
% 	
% 	for j = 1:length(xs),
% 		ls(j) = ys(j) * lagrange_coefficient(x,j,xs,ys);
% 	end
% 	
% 	y = sum(ls);
% 		
% 		
% 
% 
% 
% end
% 
% function lj =  lagrange_coefficient(x,j, xs, ys)
% 	
% 	notj = 1:length(xs); notj = notj(notj ~= j);
% 	
% 	top = x - xs(notj);
% 	bottom = xs(j) - xs(notj);
% 	
% 	lj = prod(top)/prod(bottom);
% end