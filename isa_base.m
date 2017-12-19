function [cs_SCF,gs_SGF,ns_TF,info_,s_RF,R_floors] = ...
    isa_base(data,varargin)


%% Input handling
inputs = inputParser;
inputs.addRequired('data');
inputs.addParamValue('Normalisation','Double', ...
    @(x) any(strcmpi(x,{'Double','D','Single','S','DoubleSingle','DS', ...
    'SingleDouble','SD'})));
inputs.addParamValue('SignatureG',1,@(x) ismember(x,[-1,0,1]));
inputs.addParamValue('SignatureC',0,@(x) ismember(x,[-1,0,1]));
inputs.addParamValue('SeedSparsity',2,@(x) x>0);
inputs.addParamValue('SeedCount',100,@(x) x>0);
inputs.addParamValue('SeedMatrix',[]);
inputs.addParamValue('DeltaSame',0.95);
inputs.addParamValue('DeltaConverged',0.99);
inputs.addParamValue('ThresholdsG',1:3);
inputs.addParamValue('ThresholdsC',1:3);
inputs.addParamValue('MaxIterationSteps',50,@(x) x>0);
inputs.addParamValue('SweepDirection',0,@(x) ismember(x,[-1,0,1]));
inputs.parse(data,varargin{:})

global opt_normalisation opt_sweepdirection
opt_normalisation = inputs.Results.Normalisation;
opt_sweepdirection = inputs.Results.SweepDirection;

global sgg sgc dc_same dc_conv ni
sgc = inputs.Results.SignatureC;
sgg = inputs.Results.SignatureG;
dc_same = inputs.Results.DeltaSame;
dc_conv = inputs.Results.DeltaConverged;
ni = inputs.Results.MaxIterationSteps;

nl_thg = inputs.Results.ThresholdsC;
nl_thc = inputs.Results.ThresholdsG;
seedcount = inputs.Results.SeedCount;
seedsparsity = inputs.Results.SeedSparsity;
seedmatrix = inputs.Results.SeedMatrix;

global nc ng
cg_EE = inputs.Results.data;
[nc,ng] = size(cg_EE);


%% Messages
global id_log

id_log = 1;
msg.nann = 'ISA/base: Data contains NaNs\n          Using NaN-handling multiplications.\n';
msg.nany = 'ISA/base: Data contains no NaNs\n';
msg.norm = ['Normalisation: ' opt_normalisation '\n'];


%% NaN test
global tt_nan
tt_nan = any(isnan(cg_EE(:)));
if tt_nan == 1
    fprintf(id_log,msg.nann); 
else
    fprintf(id_log,msg.nany); 
end


%% Normalisation
global cg_EG gc_EC
[gc_EC,cg_EG] = mod_normalisation(cg_EE,opt_normalisation);


%% Mode
msg.date = ['Date:          ',datestr(now,'yyyy-mm-dd HH:MM:SS.FFF\n')];


%% Build seeds
if isempty(seedmatrix);
    cs_SC0 = mod_seed(seedcount,seedsparsity);
else
    cs_SC0 = seedmatrix;
end


%% ISA
if nargout > 4
    msg.core = 'Mode:          mod_wrapper.m\n';
    [cs_SCF,gs_SGF,ns_TF,s_RF,R_floors] = ...
        mod_wrapper(cg_EE,cs_SC0,nl_thc,nl_thg);
else
    msg.core = 'Mode:          mod_wrapper_norob.m\n';
    [cs_SCF,gs_SGF,ns_TF] = ...
        mod_wrapper_norob(cs_SC0,nl_thc,nl_thg);
end


%% Run information
msg.prei = '\\\\ info\n';
msg.posi = '// info\n';
msg.ssep = ['----------------------------------------------\n'];
msg.sttc = ['Genes:         ',num2str(ng,'%04d'),'\n'];
msg.sttb = ['Conditions:    ',num2str(nc,'%04d'),'\n'];
msg.sttm = ['Modules:       ',num2str(size(gs_SGF,2),'%04d'),'\n'];
msg.sttd = ['c-threshold:   length ',num2str(length(nl_thc),'%02d'),...
    ' / min ',num2str(min(nl_thc),'%4.2f'),...
    ' / max ',num2str(max(nl_thc),'%4.2f'),'\n'];
msg.stte = ['g-threshold:   length ',num2str(length(nl_thg),'%02d'),...
    ' / min ',num2str(min(nl_thg),'%4.2f'),...
    ' / max ',num2str(max(nl_thg),'%4.2f'),'\n'];
msg.sttf = ['Signatures:    c ',num2str(sgc),' / g ',num2str(sgg),'\n'];
msg.sttg = ['Deltas:        conv ',num2str(dc_conv),' / same ',...
    num2str(dc_same),'\n'];

info_ = [msg.ssep,msg.core,msg.norm,msg.ssep,msg.date,msg.ssep,...
    msg.sttb,msg.sttc,msg.sttm,msg.sttd,...
    msg.stte,...
    msg.sttf,msg.sttg,msg.ssep];
