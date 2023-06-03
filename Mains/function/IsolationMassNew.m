function IsolationMassNew(Data, CurtIndex, Tree, result,Harmonic,NodeOrder)
% 
% Function IsolationMassNew: estimate the mass and depth of test instances on an isolation tree
% 
% Inputs:
%     Data: n x d matrix; n: # of instance; d: dimension;
%     CurtIndex: vector; indices of the current data instances;
%     Tree: structure; a half space tree;
%     mass: n x 1 vector; previously estimated mass;
%     NodeOrder: n x NumSub matrix; previously node indices
% 
% Outputs:
%     mass: currently estimated mass;
%     depth: currently estimated depth;
%     NodeInd: node indices
% 
% Reference:
%     F. T. Liu, K. M. Ting, and Z.-H. Zhou.
%     Isolation Forest.
%     In Proceedings of ICDM, pages 413-422, 2008.
% 
% Copyright by Guang-Tong Zhou, April, 22, 2012 (zhouguangtong@gmail.com).
% Modified by Bo Shen, May, 17th, 2021 (boshen@vt.edu)
if Tree.NodeStatus == 0
    if Tree.Size == 0
    disp("issue: tree size = 0")
    end    
    
    if Tree.Size <= 1
        result.mass(CurtIndex) = Tree.Height;
        result.NodeInd(CurtIndex,:) = NodeOrder(CurtIndex,:);
    else
%         c = 2 * (log(Tree.Size - 1) + 0.5772156649) - 2 * (Tree.Size - 1) / Tree.Size;
        c = 2 * ( Harmonic(Tree.Size) - 1);
        result.mass(CurtIndex) = Tree.Height + c;
        result.NodeInd(CurtIndex,:) = NodeOrder(CurtIndex,:);
    end
    return;
    
else
 
      CurtData = Data(CurtIndex, Tree.SplitAttribute);
    % this may cause some of test samples have 0 mass. 
%     LeftCurtIndex  = CurtIndex(((CurtData >= Tree.LowerLimit)  & (CurtData < Tree.SplitPoint)));
%     RightCurtIndex = CurtIndex(((CurtData <= Tree.UpperLimit)  & (CurtData >= Tree.SplitPoint)));
    % this will not have the case that test samples have 0 mass.
      LeftCurtIndex  = CurtIndex(CurtData < Tree.SplitPoint);
      RightCurtIndex = setdiff(CurtIndex, LeftCurtIndex);
%     RightCurtIndex = CurtIndex(CurtData >= Tree.SplitPoint);

    % initialize the node index when the height = 0   
    if Tree.Height == 0
%            NodeOrder = zeros(size(Data,2),1);
           NodeOrder(LeftCurtIndex,1)  = 1;
           NodeOrder(RightCurtIndex,1) = 2;
    end
    
    if ~isempty(LeftCurtIndex)
        if Tree.Height >= 1
        NodeOrder(LeftCurtIndex,Tree.Height+1)  = 2 * NodeOrder(LeftCurtIndex,Tree.Height) + 1;
        end
        IsolationMassNew(Data, LeftCurtIndex, Tree.LeftChild, result,Harmonic,NodeOrder);
    end
    
    if ~isempty(RightCurtIndex)
        if Tree.Height >= 1
        NodeOrder(RightCurtIndex,Tree.Height+1)  = 2 * NodeOrder(RightCurtIndex,Tree.Height) + 2;
        end
        IsolationMassNew(Data, RightCurtIndex, Tree.RightChild, result,Harmonic,NodeOrder);
    end
    
%      mass(CurtIndex(Data(CurtIndex, Tree.SplitAttribute) < Tree.LowerLimit)) = 0;
%      mass(CurtIndex(Tree.UpperLimit < Data(CurtIndex, Tree.SplitAttribute))) = 0;

end
