function [gc_EC,cg_EG] = mod_normalisation(cg_EE,opt)

if strcmpi(opt,'Double');
    cg_EG = fun_normalize(fun_normalize(cg_EE,1),2);
    cg_EC = fun_normalize(fun_normalize(cg_EE,2),1);
    gc_EC = cg_EC';
elseif strcmpi(opt,'Single');
    cg_EG = fun_normalize(cg_EE,2);
    cg_EC = fun_normalize(cg_EE,1);
    gc_EC = cg_EC';
elseif strcmpi(opt,'SD');
    cg_EC = fun_normalize(cg_EE,1);
    cg_EG = fun_normalize(cg_EC,2);
    gc_EC = cg_EC';
else
    error('mod_normalisation:invalid','No valid normalisation option');
end
