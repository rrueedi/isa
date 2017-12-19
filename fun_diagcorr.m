function c_Z = fun_diagcorr(cg_A,cg_B)

if size(cg_A)~=size(cg_B)
    error('Matrices must have the same size')
end

cg_A = cg_A - repmat(mean(cg_A,1),size(cg_A,1),1);
cg_B = cg_B - repmat(mean(cg_B,1),size(cg_B,1),1);
c_A_sumsq = sum(cg_A.^2,1);
c_B_sumsq = sum(cg_B.^2,1);

c_AB = sum(cg_A.*cg_B,1);
c_X = sqrt(c_A_sumsq.*c_B_sumsq);

c_Z = c_AB./c_X;
