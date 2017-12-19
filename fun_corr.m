function [ss_Z p] = fun_corr(ws_A,ws_B)

if (size(ws_A,1)~=size(ws_B,1))
    error('Matrices must have the same number of rows.')
end

ws_A = ws_A - repmat(mean(ws_A,1),size(ws_A,1),1);
ws_B = ws_B - repmat(mean(ws_B,1),size(ws_B,1),1);
ss_X = repmat(sum(ws_A.^2,1)',1,size(ws_B,2));
ss_Y = repmat(sum(ws_B.^2,1) ,size(ws_A,2),1);

ss_AB = ws_A'*ws_B;
ss_XY = sqrt(ss_X.*ss_Y);

ss_Z = ss_AB./ss_XY;

if nargout>1
    simnum = 1e3;
    [dummy,sp] = sort(rand(nr,simnum),1);
    c = reshape(ws_B(sp,:),nr,simnum*size(ws_B,2));
    r0 = corrz0(ws_A,c);
    l_cnt = zeros(size(r));
    h_cnt = zeros(size(r));
    for i=1:simnum
        idx = i+simnum*(0:(size(ws_B,2)-1));
        l_cnt = l_cnt+double(r0(:,idx)>r);
        h_cnt = h_cnt+double(r0(:,idx)<r);
    end
    l_cnt = l_cnt/simnum;
    h_cnt = h_cnt/simnum;
    p = 2*min(l_cnt,h_cnt);
end
    