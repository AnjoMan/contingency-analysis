%commands in this script run at matlab startup

set(0,'DefaultFigureWindowStyle','docked')

%parallel computing
matlabpool('open');

%set up jave for progess bars
pctRunOnAll javaaddpath 'C:\Users\Anton\Development\ParforProgMonv2\java'