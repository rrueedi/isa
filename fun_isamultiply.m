function cs_Z = fun_isamultiply(cg_A,gs_B)
global tt_nan
if (tt_nan == 0)
    cg_A_ones = ones(size(cg_A));
    cs_Z = cg_A*gs_B./sqrt(cg_A_ones*(gs_B.^2));
elseif (tt_nan == 1)
    cg_M = ~isnan(cg_A);
    cg_A_nonan = cg_A;
    cg_A_nonan(~cg_M) = 0;
    cs_v = cg_A_nonan*gs_B;
    cs_w = (cg_M*(gs_B.^2)).^.5;
    cs_Z = cs_v./cs_w;
    cs_Z(cs_w==0) = 0;
end
