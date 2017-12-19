function cg_Z = fun_normalize(cg_A,dim)
% Normalises the input matrix according to dimension dim.
% The normalisation is (x-mean(x))/s(x), with s the sample variance of x.

global tt_nan
% default dimension
if nargin < 2; dim = 1; end

[nv no] = size(cg_A);
sz_A = [nv no];

if (tt_nan == 0)
    w_A_mean_k = mean(cg_A,dim);
    
elseif (tt_nan == 1)
    cg_A_k = cg_A;
    cg_K_a = isnan(cg_A);
    cg_A_k(cg_K_a==1) = 0;
    
    w_A_len_k = sum(1-cg_K_a,dim);
    w_A_len_k_0 = (w_A_len_k==0);
    
    w_A_mean_k = sum(cg_A_k,dim)./w_A_len_k;
    w_A_mean_k(w_A_len_k_0) = 0;
    
end

if (dim == 1)
    for j=1:no
        cg_A(:,j) = cg_A(:,j) - w_A_mean_k(j);
    end
    
elseif (dim == 2)
    for j=1:nv
        cg_A(j,:) = cg_A(j,:) - w_A_mean_k(j);
    end
    
end

if (tt_nan == 0)
    w_A_var_k = sqrt( sum(cg_A.^2,dim)/(sz_A(dim)-1) );
    
elseif (tt_nan == 1)
    cg_A_sq = cg_A.^2;
    cg_A_sq(cg_K_a==1) = 0;
    w_A_len_k_1 = (w_A_len_k<=1);
    
    w_A_var_k = sqrt( sum(cg_A_sq,dim)./(w_A_len_k-1) );
    w_A_var_k(w_A_len_k_1) = NaN;
    
end

if dim == 1
    for j=1:no
        cg_A(:,j) = cg_A(:,j)/w_A_var_k(j);
    end
    
elseif dim == 2
    for j=1:nv
        cg_A(j,:) = cg_A(j,:)/w_A_var_k(j);
    end
    
end

cg_Z = cg_A;
