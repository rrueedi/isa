function [me sd] = fun_meanstd(a,dim)
% Gives both mean and standard deviation
% By not having to recompute the mean, this function is up to 25% faster than
% the separate computation

if nargin<2; dim=1;end

me = mean(a,dim);
sd = sqrt((size(a,dim)/(size(a,dim)-1))*(mean(a.^2,dim) - me.^2));
