base  = loadcase('case30_mod.mat');





mfault = Fault('single bus fault', {[],[9],[]});


faultCase = mfault.applyto(base, true);

% mplot.faulted(base, mfault);