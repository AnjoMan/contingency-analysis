% clear all; clos

%% Run CPFs
tic;
base = loadcase('case30_mod.mat');
% base = loadcase('case118_mod.mat');
[CPFloads, messages,branchFaults, base, baseLoad] = cpf_compare(base);



time = toc;


if time/60 > 1,
	fprintf('CPF completed in %d:%2.0f minutes\n', floor(time/60), time-floor(time/60)*60);
else
	fprintf('CPF completed in %.3f seconds\n', time);
end

%simplify 'branchFaults' to structs (Python doesn't understand matlab
%objects)
% for i=1:length(branchFaults),
% 	branchFaults{i} = branchFaults{i}.tostruct();
% end


save cpfResults.mat CPFloads messages branchFaults base baseLoad























% 
% %% Get graph ready
% 
% load cpfResults.mat
% 
% close all;
% 
% baseCPF = cpf(base);
% 
% % baseLambda = baseCPF.max_lambda;
% nBranches = length(base.branch(:,1));
% 
% branchLoads = cell(1, nBranches);
% faults_branch = cell(1, nBranches);
% %% Collect CPF cases by branch
% for i = 1:length(branchFaults)
% 	
% 	for j = 1:length(branchFaults{i}),
% 		branchLoads{branchFaults{i}(j)} = [branchLoads{branchFaults{i}(j)} i];
% 	end
% 	
% end
% 
% 
% CPFreductions = zeros(1, length(nBranches));
% 
% % baseLambda = baseCPF.max_lambda;
% 
% reductions = cell(1,length(nBranches));
% avgReductions = zeros(1, length(branchLoads));
% for i = 1:length(branchLoads),
% 	reductions{i} = baseLoad - CPFloads(branchLoads{i});
% 	avgReductions(i) = mean(reductions{i});
% end
% 
% r = treemap(avgReductions);
% 
% plotRectangles(r);
% 
% %% Lay out sub-levels
% 
% % Lay out each column within that column's rectangle from the overall
% % layout
% 
% treemapLayouts = cell(1, nBranches);
% for j = 1:nBranches,
% 	m = length(reductions{j});
% 	
% 	colorsA = 7  * repmat(rand(1,3), m,1);
% 	colorsB = 3*rand(m,3);
% 	colors = (colorsA +colorsB)/10;
% 	
% 	w = r(3,j); h = r(4,j);
%     rNew = treemap(reductions{j},r(3,j),r(4,j));
% 	
% 	rCorners = [rNew(1,:) + rNew(3,:); rNew(2,:) + rNew(4,:)];
% 	breaks = rCorners(1,:) > w | rCorners(2,:) > h;
% 
% 	rCorners(1,rCorners(1,:)>w) = w;
% 	rCorners(2,rCorners(2,:)>h) = h;
% 	
% 	rNew(3,:) = rCorners(1,:) - rNew(1,:);
% 	rNew(4,:) = rCorners(2,:) - rNew(2,:);
% 	
% 
% 	treemapLayouts{j} = rNew';
% %     rNew(1,:) = rNew(1,:) + r(1,j);
% %     rNew(2,:) = rNew(2,:) + r(2,j);
% %     plotRectangles(rNew,[],colors)
% end
% 
% treemapLayouts = [r' treemapLayouts];
% 
% file = fopen('branch_LoadReductions.csv', 'w');
% fprintf(file,'from, to, load reduction\n');
% for i = 1:length(avgReductions),
% 	fprintf(file,'%d, %d, %f\n', base.branch(i,1), base.branch(i,2), avgReductions(i));
% end
% 
% fclose(file);
% save treemapLayouts_118.mat treemapLayouts
% % plotRectangles(r);
% % outline(r)
% % axis([-0.01 1.01 -0.01 1.01])
% 
% 
