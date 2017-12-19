function cg_ZZ = fun_shuffle(cg_EE)

[nc ng] = size(cg_EE);
[dummy,permutation] = sort(rand(nc*ng,1));

cg_ZZ = reshape(cg_EE(permutation),nc,ng);
