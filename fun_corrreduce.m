function [Z,sel] = fun_corrreduce(A,dc)
% removes columns from matrix A which have a correlation > dc with any
% previous column in A

CR = abs( corrcoef(A) ) > dc;
CR = tril(CR,0);
sel = sum(CR,2) == 1;
Z = A(:,sel);