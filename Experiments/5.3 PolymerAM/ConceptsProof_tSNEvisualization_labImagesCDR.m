%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Note: This is code for testing feedback anomaly detection with
%%%%%%%%%%  online optimization (good implementation); 
%%%%%%%%%%  the case for the lab images
%%%%%%%%%%  Date: 7/18/2021, Bo Shen, email: boshen@vt.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sampleInd = [101:500];
Data     = dat_raw(sampleInd,:);
ADLabels = [zeros(1,358) ones(1,42)]';

sum(ADLabels)
% Data = randi([3, 4], [2000,40]);
%% isolation forest 
rounds = 10; % rounds of repeat
% parameters for iForest
NumTree = 100; % number of isolation trees
NumSub = 2^8; % subsample size
NumDim = size(Data, 2); % do not perform dimension sampling 
 
% auc = zeros(rounds, 1);
% mtime = zeros(rounds, 2);
rseed = zeros(rounds, 1);
tStart = tic;
r = 3;
    disp(['rounds ', num2str(r), ':']);
    
    rseed(r) = sum(1000 * r);
    Forest = IsolationForest(Data, NumTree,NumSub,rseed(r));

    [Mass, Nodes, tt] = IsolationEstimationNew(Data, Forest);
%     tt
%% gradient descent setup
    Features = Nodes2Binary(Nodes);
    sum(Features{1}(:,1:2),'all')
    rng(2,'philox')
    sampleIndex = randperm(size(Data,1));
    YLabels = ADLabels(sampleIndex);
    % YLabels = ADLabels;
    YLabels(YLabels==0) = -1; 
    TransferData = [];
    for jj = 1:NumTree
        TransferData = [TransferData Features{jj}];
    end
    TransferData =  TransferData(sampleIndex,:);

    T = 300;
    tic
    ResultNonneg = OnlineOptimiation(TransferData, YLabels, T);
    toc

    optionsTruncated.gradientUpdate = 'truncated';
    optionsTruncated.Cost = [100,0.001];
    tic
    ResultTuncated = OnlineOptimiation(TransferData, YLabels, T, optionsTruncated);
    toc

%     optionsTruncated.Cost = [1,1];
%     tic
%     ResultTuncated2 = OnlineOptimiation(TransferData, YLabels, T, optionsTruncated);
%     toc

    optionsSparseRecovery.gradientUpdate = 'sparse-recovery';
    optionsSparseRecovery.Cost = [100,0.001];
    optionsSparseRecovery.Sparsity = 4000;
    optionsSparseRecovery.SRratio =0.1;
    tic
    ResultSparseRecovery = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
    toc
    
%     optionsSparseRecovery.SRratio =0.2;
%     tic
%     ResultSparseRecovery2 = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
%     toc
%     
%     optionsSparseRecovery.SRratio =0.3;
%     tic
%     ResultSparseRecovery3 = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
%     toc
%     
%     optionsSparseRecovery.SRratio =0.4;
%     tic
%     ResultSparseRecovery4 = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
%     toc
%     
tEnd = toc(tStart) 

%% Prepare data for visualization
T2 = 100;
NewLabels =    YLabels;
Fun =  ResultSparseRecovery.HumanFeedOutput; % ResultTuncated 
sum(Fun(1:T2,2)>0)
for tt = 1:T2
NewLabels(Fun(tt,1)) = YLabels(Fun(tt,1))+Fun(tt,2);
end
rng('default') % for fair comparison
Y = tsne(TransferData,'Algorithm','exact','Distance','cosine');
% r = 1  works good; donot change the code
% rng('default') % for fair comparison
% Y = tsne(Data,'Algorithm','exact','Distance','chebychev');
% 
% rng('default') % for fair comparison
% Y = tsne(Data,'Algorithm','exact','Distance','euclidean');

