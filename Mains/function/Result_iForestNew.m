classdef Result_iForestNew < handle
    properties
        mass = [];
        NodeInd = [];
    end
    
    methods
        
        function result = Result_iForestNew(n,m)
            result.mass = zeros(n,1);
            result.NodeInd = zeros(n,m);
        end
        
    end
    
end
    