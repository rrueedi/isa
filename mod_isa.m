function [cs_SCF,gs_SGF] = mod_isa(gc_EC,cg_EG,cs_SC,thc,thg)
% Apply the ISA to a list of seeds cs_SC at a given pair of thresholds.
% Required global definitions:
% # sgc/sgg: condition/gene signatures
% # dc_same/dc_conv: min correlations values for which seeds are 
%   considered equal/converged
% # ni: maximum number of iterations


%% Global variables
global dc_same dc_conv ni sgc sgg



%% Initialise variables

[nc ng] = size(cg_EG);

gs_SG_proj = fun_isamultiply(gc_EC,cs_SC);
gs_SG_prev = fun_signature(gs_SG_proj,thg,sgg);

gs_SGF = [];
cs_SCF = [];


%% Iteration

it = 0;

while ( ...
        ~isempty(gs_SG_prev) && ...
        it < ni ...
        )
    
    it = it + 1;
    
    
    % iteration step (signature)
    
    cs_SC_proj = fun_isamultiply(cg_EG,gs_SG_prev);
    cs_SC = fun_signature(cs_SC_proj,thc,sgc);
    gs_SG_proj = fun_isamultiply(gc_EC,cs_SC);
    gs_SG = fun_signature(gs_SG_proj,thg,sgg);
    
    
    % move converged seeds (= modules) into final lists
    % keep non-converged seeds
    
    sel_converged = ( fun_diagcorr(gs_SG_prev,gs_SG) > dc_conv );
   
    ycnv = find( sel_converged);
    ncnv = find(~sel_converged);
    
    cs_SC_prev = cs_SC;
    gs_SG_prev = gs_SG;
    
    if ( ~isempty(ycnv) )
         gs_SGF = [gs_SGF gs_SG(:,ycnv)];
         cs_SCF = [cs_SCF cs_SC(:,ycnv)];
    end
    
    cs_SC_prev = cs_SC_prev(:,ncnv);
    gs_SG_prev = gs_SG_prev(:,ncnv);
    
    
    % remove null-seeds
    
    sel_nonnull = find( any(gs_SG_prev~=0) );
    gs_SG_prev = gs_SG_prev(:,sel_nonnull);
    cs_SC_prev = cs_SC_prev(:,sel_nonnull);
    
    
    % remove duplicates among final and running lists
    
    if ( ng < nc )
        ss_CR = corrcoef([gs_SGF gs_SG_prev]);
    else
        ss_CR = corrcoef([cs_SCF cs_SC_prev]);
    end
    
    ss_CR = abs(ss_CR) > dc_same;
    ns = size(cs_SCF,2);
    
    if ( size(gs_SG_prev,2) > 0 )
        ss_CR = tril(ss_CR,0);
        sel = find( sum(ss_CR,2)==1 );
        sel_gns = sel( sel>ns ) - ns;
        sel_lns = sel( sel<=ns );
        gs_SG_prev = gs_SG_prev(:,sel_gns);
        cs_SCF = cs_SCF(:,sel_lns);
        gs_SGF = gs_SGF(:,sel_lns);
    end
end
