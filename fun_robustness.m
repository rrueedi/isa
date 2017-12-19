function [s_R] = fun_robustness(gc_EC,cg_EG,cs_SC,gs_SG)
% Computes the module robustness.
cs_SC_normalised = cs_SC./repmat( ...
    sqrt(sum(cs_SC.^2,1)),size(cs_SC,1),1);
gs_SG_normalised = gs_SG./repmat( ...
    sqrt(sum(gs_SG.^2,1)),size(gs_SG,1),1);
s_rC = sum(cs_SC_normalised.*fun_isamultiply(cg_EG,gs_SG_normalised),1);
s_rG = sum(gs_SG_normalised.*fun_isamultiply(gc_EC,cs_SC_normalised),1);

s_R = sqrt(s_rG.*s_rC);
