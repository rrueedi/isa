function [cs_SCF,gs_SGF,ns_TF] = mod_wrapper_norob( ...
    cs_SC0,nl_thc,nl_thg)

%% Global variables
global id_log cg_EG gc_EC opt_sweepdirection


%% Messages
msg.inru = 'ISA/wrap: Running ISA on %03d seeds ...\n';
msg.swee = 'ISA/wrap: Running sweep on %03d modules ...\n';
msg.nomo = 'ISA/wrap: No modules found.\n';
msg.mcnt = '          module count %03d.\n';
msg.nosw = 'ISA/wrap: Single threshold pair, not sweeping.\n';
msg.floo = 'ISA/wrap: computing robustness floors\n';
msg.flod = '          -- th (%4.2f,%4.2f) / mods %d / floor %4.2f\n';


%% ISA on seeds
nthc = length(nl_thc);
nthg = length(nl_thg);

gs_SGF = [];
cs_SCF = [];
ns_TF = [];

fprintf(id_log,msg.inru,size(cs_SC0,2));

cnt = 0;
tst_cnt = nthc*nthg>20;
for jthc = 1:nthc
    for jthg = 1:nthg
        
        if tst_cnt
        cnt = vis_progress(cnt,5,50,'          ');
        end
        
        [cs_SCF,gs_SGF,ns_TF] = mod_core_norob( ...
            gc_EC,cg_EG, ...
            cs_SCF,gs_SGF,ns_TF, ...
            cs_SC0,nl_thc(jthc),nl_thg(jthg));
    end
end
if tst_cnt
    fprintf('\n');
end
fprintf(id_log,msg.mcnt,size(gs_SGF,2));


%% Sweep
if ( nthg*nthc > 1 )
    if ~isempty(gs_SGF);
        fprintf(id_log,msg.swee,size(gs_SGF,2));
        [cs_SCF,gs_SGF,ns_TF] = mod_sweep_norob(gc_EC,cg_EG,...
            cs_SCF,gs_SGF,ns_TF, ...
            nl_thc,nl_thg);
        fprintf(id_log,msg.mcnt,size(gs_SGF,2));
    else
        fprintf(id_log,msg.nomo);
    end
else
    fprintf(id_log,msg.nosw);
end


%% Sweep sub-function
    function [cs_SCF,gs_SGF,ns_TF] = mod_sweep_norob( ...
            gc_EC,cg_EG, ...
            cs_SCF,gs_SGF,ns_TF, ...
            nl_thc,nl_thg)
        
        % Use modules found at a given pair of thresholds as seeds for all other
        % threshold pairs, moving either up, down, or in both directions along
        % threshold lists.
        
        nthg = length(nl_thg);
        nthc = length(nl_thc);
        
        if ( opt_sweepdirection >= 0 )
            for jthc_ = 1:nthc
                for jthg_ = 1:nthg
                    if ( jthc_ < nthc )
                        sel_seeds = ...
                            ns_TF(1,:) == nl_thc(jthc_) & ...
                            ns_TF(2,:) == nl_thg(jthg_);
                        [cs_SCF,gs_SGF,ns_TF] = mod_core_norob(gc_EC,cg_EG, ...
                            cs_SCF,gs_SGF,ns_TF,gs_SGF(:,sel_seeds), ...
                            nl_thc(jthc_+1),nl_thg(jthg_));
                    end
                end
                for jthg_ = 1:nthg-1
                    sel_seeds = ...
                        ns_TF(1,:) == nl_thc(jthc_) & ...
                        ns_TF(2,:) == nl_thg(jthg_);
                    [cs_SCF,gs_SGF,ns_TF] = mod_core_norob(gc_EC,cg_EG, ...
                        cs_SCF,gs_SGF,ns_TF,gs_SGF(:,sel_seeds), ...
                        nl_thc(jthc_),nl_thg(jthg_+1));
                end
            end
        end
        if ( opt_sweepdirection <= 0 )
            for jthc_ = nthc:-1:1
                for jthg_ = nthg:-1:1
                    if ( jthc_ > 1 )
                        sel_seeds = ...
                            ns_TF(1,:) == nl_thc(jthc_) & ...
                            ns_TF(2,:) == nl_thg(jthg_);
                        [cs_SCF,gs_SGF,ns_TF] = mod_core_norob(gc_EC,cg_EG, ...
                            cs_SCF,gs_SGF,ns_TF,gs_SGF(:,sel_seeds), ...
                            nl_thc(jthc_-1),nl_thg(jthg_));
                    end
                end
                for jthg_ = nthg:-1:2
                    sel_seeds = ...
                        ns_TF(1,:) == nl_thc(jthc_) & ...
                        ns_TF(2,:) == nl_thg(jthg_);
                    [cs_SCF,gs_SGF,ns_TF] = mod_core_norob(gc_EC,cg_EG, ...
                        cs_SCF,gs_SGF,ns_TF,gs_SGF(:,sel_seeds), ...
                        nl_thc(jthc_),nl_thg(jthg_-1));
                end
            end
        end
    end
end