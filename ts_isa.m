function ts = ts_isa(ix,addNaNs)
if nargin<2; addNaNs = 0; end
if nargin<1; ix = 0 ; end

lof = dir('ts/ts.*.csv');
if ix == 0 | ix > length(lof)
  fprintf('\nrun this test as a function of the input file index, chosing among the following: \n\n')
  for ii = 1:length(lof)
    fprintf('%2d -- %s\n',ii,lof(ii).name);
  end
  fprintf('\nA file named ts.ab.cd.csv contains a matrix with b*10^a rows and d*10^c columns.\n');
  return
end
%
% ----- ----------------
%       import test data
%       ---------------- -----
%
lof = dir('ts/ts.*.csv');
ts.mx = csvread(fullfile('ts',lof(ix).name));
if addNaNs
  dd = prod(size(ts.mx));
  se = randi(dd,ceil(dd/100),1);
  ts.mx(se) = NaN;
end
%
% ----- ------------------
%       set ISA parameters
%       ------------------ -----
%
ts.isa.delta_same = 0.75;
ts.isa.tg = [2.2,2.5,2.8];
ts.isa.tc = [1,2,3];
ts.isa.sigg = 0;
ts.isa.sigc = 1;
%
% ----- -------
%       run ISA 
%       ------- -----
%
tic;
[ts.isa.cs_scf,ts.isa.gs_sgf,ts.isa.ns_tf,ts.isa.info,ts.isa.s_rf,ts.isa.r_floors] = ...
    isa_base(ts.mx ...
    ,'DeltaSame',  ts.isa.delta_same ...
    ,'ThresholdsG',ts.isa.tg ...
    ,'ThresholdsC',ts.isa.tc ...
    ,'SignatureG', ts.isa.sigg ...
    ,'SignatureC', ts.isa.sigc ...
    );
ts.runtime=toc;
