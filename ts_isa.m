%
% ----- ----------------
%       import test data
%       ---------------- -----
%
ts.mx = csvread( 'ts/ts.csv' );
ts.mx(ts.mx==0) = NaN;
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
[ts.isa.cs_scf,ts.isa.gs_sgf,ts.isa.ns_tf,ts.isa.info,ts.isa.s_rf,ts.isa.r_floors] = ...
    isa_base(ts.mx ...
    ,'DeltaSame',  ts.isa.delta_same ...
    ,'ThresholdsG',ts.isa.tg ...
    ,'ThresholdsC',ts.isa.tc ...
    ,'SignatureG', ts.isa.sigg ...
    ,'SignatureC', ts.isa.sigc ...
    );
