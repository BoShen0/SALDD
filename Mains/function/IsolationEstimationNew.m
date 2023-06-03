function [Mass, Nodes,ElapseTime] = IsolationEstimationNew(TestData, Forest)
% 
% Function IsolationEstimation: estimate test instance mass and nodes on isolation forest
% 
% Inputs:
%     TestData: test data; nt x d matrix; nt: # of test instance; d: dimension;
%     Forest: structure; isolation forest model;
% 
% Outputs:
%     Mass: nt x NumTree matrix; mass of test instances;
%     Nodes: a cell of node features
%     ElapseTime: elapsed time;
% 
% Reference:
%     F. T. Liu, K. M. Ting, and Z.-H. Zhou.
%     Isolation Forest.
%     In Proceedings of ICDM, pages 413-422, 2008.
% 
% Copyright by Guang-Tong Zhou, April, 22, 2012 (zhouguangtong@gmail.com).
% Modified by Bo Shen, May, 17th, 2021 (boshen@vt.edu)
NumInst = size(TestData, 1);
Mass = zeros(NumInst, Forest.NumTree);
Harmonic = GetHarmonicSeries(Forest.NumSub);
Nodes = cell(Forest.NumTree,1);

tStart = tic;
parfor k = 1:Forest.NumTree % parallel for loop to speed up the codes
    % Forest.HeightLimit + 1 is for safe
    result = Result_iForestNew(NumInst, Forest.HeightLimit + 1);
    NodeTemp = zeros(NumInst, Forest.HeightLimit + 1);
    IsolationMassNew(TestData, 1:NumInst, Forest.Trees{k, 1}, result,Harmonic,  NodeTemp); %Harmonic
    Mass(:, k) = result.mass;
    Nodes{k} =  result.NodeInd;
end
ElapseTime =  toc(tStart);

end

function Harmonic = GetHarmonicSeries(NumSub)
    Harmonic = zeros(NumSub,1);
    Harmonic(1)  = 1;
    
    for i = 2:NumSub
        Harmonic(i) = Harmonic(i - 1) + 1/i;
    end
end