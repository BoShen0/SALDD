classdef TreeNode_iForest < handle
    
    properties
        LeftChild  = [];  %TreeNode.empty;
        RightChild = []; %TreeNode.empty;
        NodeStatus = uint8(1);
        SplitAttribute = uint16(0);
        SplitPoint = 0;
        Size = 0;   
        Height = uint16(0);
        UpperLimit = 0;
        LowerLimit = 0;
    end
    
    methods
        function node = TreeNode_iForest(Data, CurtIndex, CurtHeight, Paras)
                NumInst = size(CurtIndex,2);    
                node.Height = uint16(CurtHeight);
                node.Size = NumInst;
%                

                if (length(CurtIndex) <= 1) || (CurtHeight >= Paras.HeightLimit) 
                    node.NodeStatus = uint8(0);
                    return;
                    
                else
                    % the for loop is very important to avoid selecting the
                    % feature with all the same values. we will have the
                    % same number of edges for each tree. but this may
                    % create some issues for some datasets
                    v = 0;
                    counter = 0;
                    while v == 0
                     % randomly select a splitting attribute
                    SplitAttributeValue = uint16(randi(Paras.NumDim));
                    CurtData = Data(CurtIndex, SplitAttributeValue);                
                    v = max(CurtData) - min(CurtData);
                    counter = counter + 1;
                        if counter > Paras.NumDim
                           break
                        end
                    end
                   
                    node.SplitAttribute = SplitAttributeValue;
                    node.SplitPoint = min(CurtData) + (v) * rand(1);

                    node.UpperLimit = node.SplitPoint +  v;
                    node.LowerLimit = node.SplitPoint - v;

                    % bulit right and left trees
                    node.LeftChild = TreeNode_iForest(Data, CurtIndex(CurtData < node.SplitPoint), CurtHeight + 1, Paras);
                    node.RightChild = TreeNode_iForest(Data, CurtIndex(CurtData >= node.SplitPoint), CurtHeight + 1, Paras);
%                     clearvars CurtData v NumInst LeftCurtIndex RightCurtIndex
                end
        end
    end
end

