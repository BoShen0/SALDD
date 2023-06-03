%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Note: This is code for testing feedback anomaly detection with
%%%%%%%%%%  online optimization (good implementation); The code is used to
%%%%%%%%%%  verify the sparsity of the transfered data, given the lower
%%%%%%%%%%  bound log(n)/2(n-1) and the upper bound n+1/4(n-1) 
%%%%%%%%%%  Date: 6/17/2021, Bo Shen, email: boshen@vt.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate gaussian random data 
rng(100);
simData = normrnd(3,10,[2^16,5]);
Sparsity = [];
%% test sparsity with different number of samples
Range = 4:12;
for iter = Range
    Data = simData(1:2^iter,:);
    NumTree = 100; % number of isolation trees
    NumSub = 2^iter; % subsample size
    NumDim = size(Data, 2); % do not perform dimension sampling 

    %%%% isolation forest 
    Forest = IsolationForest(Data, NumTree,NumSub,1000);
    % for shallow case
%     Forest = IsolationForestShallow(Data, NumTree,NumSub,1000);
    [Mass, Nodes, tt] = IsolationEstimationNew(Data, Forest);
    tt
    Features = Nodes2Binary(Nodes);
    TransferData = [];
    for jj = 1:NumTree
        TransferData = [TransferData Features{jj}];
    end
    NumberElements = (2^(iter+1) - 2) * 2^iter * 100;
    % for shallow case
%     NumberElements = size(TransferData,1) * size(TransferData,2); 
    Sparsity(iter) = sum(TransferData,'all')/NumberElements;
end
NumberSamples = 2.^Range;
LowerBound = Range ./ (2.^(Range + 1) - 2);
UpperBound = (2.^Range + 1) ./ (2.^(Range + 2) - 4);
plot(LowerBound)
hold on;
plot(UpperBound )
hold on;
plot(Sparsity(Range))
hold off;
YMatrix1 = [Sparsity(Range)',LowerBound',UpperBound'];
% for shallow case
% YMatrix1 = [Sparsity(Range)'];