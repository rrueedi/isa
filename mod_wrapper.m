function [cs_SCF,gs_SGF,ns_TF,ns_RF,R_floors] = mod_wrapper( ...
    cg_EE,cs_SC0,nl_thc,nl_thg)

%% Global variables
global id_log gc_EC cg_EG opt_normalisation opt_sweepdirection


%% Messages
msg.inru = 'ISA/wrap: Initial run on %03d seeds\n';
msg.sweu = 'ISA/wrap: Running up sweep on %03d modules\n';
msg.swed = 'ISA/wrap: Running down sweep on %03d modules\n';
msg.nomo = 'ISA/wrap: No modules found\n';
msg.robu = 'ISA/wrap: Computing robustness\n';
msg.shuf = 'ISA/wrap: Run on shuffled data\n';
msg.mcnt = 'ISA/wrap: Module count %03d\n';
msg.nosw = 'ISA/wrap: Single threshold pair, no sweep\n';
msg.floo = 'ISA/wrap: Computing robustness floors ...';
msg.flod = '\n          ';


%% Define robustness floor
cg_EE_shf = fun_shuffle(cg_EE);
[gc_EC_shf,cg_EG_shf] = mod_normalisation(cg_EE_shf,opt_normalisation);

nthc = length(nl_thc);
nthg = length(nl_thg);

fprintf(id_log,msg.floo);
R_floors = zeros(nthc,nthg);

cnt_progress = 0;
fprintf(id_log,'\n');
nseeds = min(size(cs_SC0,2),50);

for jthg = 1:nthg
    for jthc = 1:nthc
        
        % show progress counter
        cnt_progress = vis_progress(cnt_progress,5,50,'          ');
        
        % find modules for shuffled data
        [cs_SC_shf,gs_SG_shf] = mod_isa( ...
            gc_EC_shf,cg_EG_shf,cs_SC0(:,1:nseeds),...
            nl_thc(jthc),nl_thg(jthg));
        
        % define robustness floor
        if ~isempty(cs_SC_shf)
            ns_R_shf = ...
                fun_robustness(gc_EC_shf,cg_EG_shf,cs_SC_shf,gs_SG_shf);
            R_floors(jthc,jthg) = max(ns_R_shf);
        end
    end
end
fprintf(id_log,'\n');


%% ISA on seeds
gs_SGF = [];
cs_SCF = [];
ns_TF = [];
ns_RF = [];

cnt_progress = 0;
fprintf(id_log,msg.inru,size(cs_SC0,2));
for jthc = 1:nthc
    for jthg = 1:nthg
        cnt_progress = vis_progress(cnt_progress,5,50,'          ');
        [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_core( ...
            gc_EC,cg_EG, ...
            cs_SCF,gs_SGF,ns_TF,ns_RF, ...
            cs_SC0,nl_thc(jthc),nl_thg(jthg),R_floors(jthc,jthg));
    end
end
fprintf(id_log,'\n');
fprintf(id_log,msg.mcnt,size(gs_SGF,2));


%% Sweep
if ( nthg*nthc > 1 )
    if ~isempty(cs_SCF);
        [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_sweep(gc_EC,cg_EG,...
            cs_SCF,gs_SGF,ns_TF,ns_RF, ...
            nl_thc,nl_thg,R_floors);
        fprintf(id_log,msg.mcnt,size(gs_SGF,2));
    else
        fprintf(id_log,msg.nomo);
    end
else
    fprintf(id_log,msg.nosw);
end


%% Sweep subfunction
    function [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_sweep( ...
            gc_EC,cg_EG, ...
            cs_SCF,gs_SGF,ns_TF,ns_RF, ...
            nl_thc,nl_thg,R_floors ...
            )
        
        % Use modules found at a given pair of thresholds as seeds for all
        % other threshold pairs, moving either up, down, or in both
        % directions along threshold lists.
        
        nthg = length(nl_thg);
        nthc = length(nl_thc);
        
        if ( opt_sweepdirection >= 0 )
            fprintf(id_log,msg.sweu,size(gs_SGF,2));
            for jthc_ = 1:nthc
                for jthg_ = 1:nthg
                    if ( jthc_ < nthc )
                        sel_seeds = ...
                            ns_TF(1,:) == nl_thc(jthc_) & ...
                            ns_TF(2,:) == nl_thg(jthg_);
                        [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_core( ...
                            gc_EC,cg_EG,cs_SCF,gs_SGF, ...
                            ns_TF,ns_RF,cs_SCF(:,sel_seeds), ...
                            nl_thc(jthc_+1),nl_thg(jthg_), ...
                            R_floors(jthc_+1,jthg_));
                    end
                end
                for jthg_ = 1:nthg-1
                    sel_seeds = ...
                        ns_TF(1,:) == nl_thc(jthc_) & ...
                        ns_TF(2,:) == nl_thg(jthg_);
                    [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_core(...
                        gc_EC,cg_EG,cs_SCF,gs_SGF, ...
                        ns_TF,ns_RF,cs_SCF(:,sel_seeds), ...
                        nl_thc(jthc_),nl_thg(jthg_+1), ...
                        R_floors(jthc_,jthg_+1));
                end
            end
        end
        
        if ( opt_sweepdirection <= 0 )
            fprintf(id_log,msg.swed,size(gs_SGF,2));
            for jthc_ = nthc:-1:1
                for jthg_ = nthg:-1:1
                    if ( jthc_ > 1 )
                        sel_seeds = ...
                            ns_TF(1,:) == nl_thc(jthc_) & ...
                            ns_TF(2,:) == nl_thg(jthg_);
                        [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_core( ...
                            gc_EC,cg_EG,cs_SCF,gs_SGF, ...
                            ns_TF,ns_RF,cs_SCF(:,sel_seeds), ...
                            nl_thc(jthc_-1),nl_thg(jthg_), ...
                            R_floors(jthc_-1,jthg_));
                    end
                end
                for jthg_ = nthg:-1:2
                    sel_seeds = ...
                        ns_TF(1,:) == nl_thc(jthc_) & ...
                        ns_TF(2,:) == nl_thg(jthg_);
                    [cs_SCF,gs_SGF,ns_TF,ns_RF] = mod_core( ...
                        gc_EC,cg_EG,cs_SCF,gs_SGF, ...
                        ns_TF,ns_RF,cs_SCF(:,sel_seeds), ...
                        nl_thc(jthc_),nl_thg(jthg_-1), ...
                        R_floors(jthc_,jthg_-1));
                end
            end
        end
    end

end
