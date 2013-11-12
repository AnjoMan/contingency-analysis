close all; clc;


myFault = Fault('test fault', {[1,2], [6], [2]});


myFault.print();


base = loadcase('case30_mod.mat');


myFault.applyto(base);