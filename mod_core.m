function [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_core( ...
    gc_EC,cg_EG, ...
    cs_SCF,gs_SGF,ns_TF,ns_RF, ...
    cs_SC0,thc,thg,R_floor)

global dc_same

% Find modules
[cs_SC,gs_SG] = mod_isa(gc_EC,cg_EG,cs_SC0,thc,thg);

if  ~isempty(cs_SC)
    
    % Remove previously found modules
    if ~isempty(cs_SCF)
        
        if ( size(cs_SCF,1) < size(gs_SGF,1) )
            CR = abs(fun_corr(cs_SCF,cs_SC));
        else
            CR = abs(fun_corr(gs_SGF,gs_SG));
        end
        
        sel_different = max(CR,[],1) < dc_same;
        gs_SG = gs_SG(:,sel_different);
        cs_SC = cs_SC(:,sel_different);
        
    end
    
    % Remove modules of robustness below floor
    ns_R = fun_robustness(gc_EC,cg_EG,cs_SC,gs_SG);
    sel_robust = ns_R > R_floor;
    ns_R = ns_R(sel_robust);
    cs_SC = cs_SC(:,sel_robust);
    gs_SG = gs_SG(:,sel_robust);
    
    % Add new module scores and their robustness to final lists, 
    % keeping track of the thresholds at which they were found
    cs_SCF = [cs_SCF cs_SC];
    gs_SGF = [gs_SGF gs_SG];
    ns_RF = [ns_RF ns_R];
    ns_TF = [ns_TF repmat([thc;thg],1,size(gs_SG,2))];

end
end
