function [vs_Z] = fun_signature(vs_A,thv,sgv)

[nv ns] = size(vs_A);

[s_A_mean s_A_stdev] = fun_meanstd(vs_A);
s_A_up = s_A_mean + thv.*s_A_stdev;
s_A_dw = s_A_mean - thv.*s_A_stdev;

vs_A_significant = zeros(nv,ns);

if (sgv == 0)
    for j = 1:ns
        vs_A_significant(:,j) = ...
            ( vs_A(:,j) > s_A_up(1,j) ) | ( vs_A(:,j) < s_A_dw(1,j) );
    end
    
elseif (sgv == 1)
    for j = 1:ns
        vs_A_significant(:,j) = ( vs_A(:,j) > s_A_up(1,j) );
    end
    
elseif (sgv == -1)
    for j = 1:ns
        vs_A_significant(:,j) = ( vs_A(:,j) < s_A_dw(1,j) );
    end
end

vs_A = vs_A .* vs_A_significant;
vs_Z = vs_A ./ repmat(max(abs(vs_A)), nv, 1);
