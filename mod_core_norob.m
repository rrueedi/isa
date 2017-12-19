function [gs_SGF,cs_SCF,ns_TF] = mod_core_norob( ...
    cg_EG,gc_EC, ...
    gs_SGF,cs_SCF,ns_TF, ...
    cs_SC0,thc,thg)

global dc_same

% Find modules
[gs_SG,cs_SC] = mod_isa(cg_EG,gc_EC,cs_SC0,thc,thg);

if  ~isempty(gs_SG)
    
    % Remove previously found modules
    if ~isempty(cs_SCF)
        
        if ( size(cs_SCF,1) < size(gs_SGF,1) )
            CR = abs(fun_corr(cs_SCF,gs_SG));
        else
            CR = abs(fun_corr(gs_SGF,cs_SC));
        end
        
        sel_different = max(CR,[],1) < dc_same;
        gs_SG = gs_SG(:,sel_different);
        cs_SC = cs_SC(:,sel_different);
        
    end
    
    % Add new module scores to final lists, keeping track of
    % the thresholds at which modules were found
    cs_SCF = [cs_SCF gs_SG];
    gs_SGF = [gs_SGF cs_SC];
    ns_TF = [ns_TF repmat([thc;thg],1,size(gs_SG,2))];

end
end