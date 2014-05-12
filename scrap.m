% close all; clear all; clc

base = loadcase('case30_mod');


faults = defineFaults(base);

mFault = faults{47};


myCase = mFault.applyto(base);


myCase = myCase{1};



out = cpf(myCase,-1,5,0.025,true)