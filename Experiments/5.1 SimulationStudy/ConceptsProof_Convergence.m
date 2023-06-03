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

%% test different sparse recovery ratio
iter = 8;
YLabels = binornd(1,0.4*ones(500,1));
Data = simData(1:500,:);
NumTree = 100; % number of isolation trees
NumSub = 2^iter; % subsample size
NumDim = size(Data, 2); % do not perform dimension sampling 

%%%% isolation forest 
Forest = IsolationForest(Data, NumTree,NumSub,1000);
[Mass, Nodes, tt] = IsolationEstimationNew(Data, Forest);
tt
Features = Nodes2Binary(Nodes);
TransferData = [];
for jj = 1:NumTree
    TransferData = [TransferData Features{jj}];
end
T = 500;
optionsSparseRecovery.gradientUpdate = 'sparse-recovery';
optionsSparseRecovery.Cost = [1,1];
optionsSparseRecovery.Sparsity = 4000;
for j=1:4
optionsSparseRecovery.SRratio =1-(0.2*j)^2;
tic
ResultSparseRecovery = OnlineOptimiationTG_SRconvergence(TransferData, YLabels, T, optionsSparseRecovery);
toc
YY{j} = ResultSparseRecovery;
end

%%% for average loss
TT = YY{1};
% YMatrix1(:,1))'* 1./(1:T)
YMatrix1 = (cumsum(TT.HumanFeedOutput(:,3))' * 1./(1:T))'; 
for j=1:4
 TT = YY{j};
 YMatrix1 = [YMatrix1 (cumsum(TT.HumanFeedOutput(:,4))' * 1./(1:T))'];
end
YMatrix1 = YMatrix1/100;
plot(cumsum(YMatrix1(:,1))'* 1./(1:T) ) %
hold on;
plot(cumsum(YMatrix1(:,2))'* 1./(1:T) ) %
hold on;
plot(cumsum(YMatrix1(:,3))'* 1./(1:T) ) %
hold on;
plot(cumsum(YMatrix1(:,4))'* 1./(1:T) ) %
hold on;
plot(cumsum(YMatrix1(:,5))'* 1./(1:T) )
hold off;
%%% for sparsity 51000
YMatrix1 = size(TransferData,2)*ones(T,1);
for j=1:4
VV = YY{j};
YMatrix1 = [YMatrix1 VV.SparsityRecovery'];
end
