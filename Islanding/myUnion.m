function [ a1 ] = myUnion( a1, a2 )
%myUnion simple union algorithm
%
% This does set union, with a few assumptions:
%
% * each starting set contains no duplicates
% * sets are one-dimensional

	a1 = unique([a1(:); a2(:)]);