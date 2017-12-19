function cs_R = mod_seed(ns,seedsparsity)

global sgg nc

if seedsparsity == 0
    
    if sgg == 0
        cs_R = 2*rand(nc,ns)-1;
    else
        cs_R = sgg*rand(nc,ns);
    end
    
else
    
    cs_R = zeros(nc,ns);
    
    for i = 1:seedsparsity
        xx = ceil(nc*rand(ns,1));
        xx = nc*(0:ns-1)' + xx;
        
        if sgg == 0
            cs_R(xx) = sign( 2*rand(1)-1 );
        else
            cs_R(xx) = sgg;
        end
        
    end
    
end

