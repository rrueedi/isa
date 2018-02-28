function cg_ZZ = fun_shuffle(cg_EE)
x = size(cg_EE);
cg_ZZ = reshape(cg_EE(randperm(prod(x))),x);
