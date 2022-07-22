classdef lsfRISDdiffusionNIparatest < lineshapeFunction
    
    properties
        params = struct('tau_o1',[]);
        g;
        c2;

        tpoints;
    end
    
    methods
        function obj = lsfRISDdiffusionNIparatest(params,str,aRFoptions)
            if nargin == 0;
                super_args = {};
            else
                super_args{1} = params;
                super_args{2} = str;
            end
            obj@lineshapeFunction(super_args);
            %obj.tpoints = maketpoints(aRFoptions);
        end
        
        function out = makeG(obj)
        
            D_m = 1/obj.params(1).tau_o1;
            
            F_para =@(t, tau) (t-tau).*((3/25).*((11.*exp(-2*D_m.*tau) + 4.*exp(-12*D_m.*tau))./(1 +0.8.*exp(-6*D_m.*tau)))); %this is the FFCF
%             F_perp =@(t) (3/25).*(7.*exp(-2.*D_m.*t) - 2.*exp(-12.*D_m.*t)) ./ (1 - 0.4.*exp(-6.*D_m.*t)); %this is the FFCF
           
            g_prime = arrayfun(@(t) integral(@(tau) F_para(t, tau),0,t),obj.tpoints); %do the numerical integration as a function of t
            out = @(t) interp1(obj.tpoints,g_prime,t);
        end
        
        function out = makeC2(obj)

        
            D_m = 1/obj.params(1).tau_o1;
            
            out = @(t) exp(-6.*D_m.*t);
        end

        function obj = maketpoints(obj,aRFoptions)
            t1 = 0:aRFoptions.dt:(aRFoptions.n_t-1)*aRFoptions.dt;
            t3 = t1;
            t2 = aRFoptions.t2_array;
            tmp = [t1,t3];
            tmp2 = [];
            for ii = 1:length(t2)
                tmp2 = [tmp2,t2(ii), t1 + t2(ii), t2(ii) + t3,t1+t2(ii)+t3];
            end
            obj.tpoints = unique([tmp,tmp2]);
            
        end
    end
end