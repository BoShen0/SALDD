%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Note: This is code for testing feedback anomaly detection with
%%%%%%%%%%  online optimization (good implementation); 
%%%%%%%%%%  the case for the metal AM images
%%%%%%%%%%  Use Metal55R7.mat
%%%%%%%%%%  Date: 6/20/2021, Bo Shen, email: boshen@vt.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data1 = zeros(8*24,80*80);
for i = 1:8
    row = (78*(i-1) + 1):(78*(i-1) + 80);
    for j = 1:24   
        col = (80*(j-1) + 1):(80*j);
        AA = double(MetalR7(row, col));
        Data1(24*(i-1)+j,:) = AA(:);
    end
end    
Anomaly1 = MetalR7(721:1280,541:620); % 541:620 is good; perhapes this is the 
% the only working case right now
Data2 = zeros(7,80*80);
for i=1:7
    row = (80*(i-1) + 1):(80*i);
    AA = Anomaly1(row,:);
    Data2(i,:) = double(AA(:));
end

Data = [Data1;Data2];
ADLabels = [zeros(1,size(Data1,1)) ones(1,size(Data2,1))];

rounds = 10; % rounds of repeat
% parameters for iForest
NumTree = 100; % number of isolation trees
NumSub = 2^8; % subsample size
NumDim = size(Data, 2); % do not perform dimension sampling 
 
auc = zeros(rounds, 1);
mtime = zeros(rounds, 2);
rseed = zeros(rounds, 1);


 r = 1;
    disp(['rounds ', num2str(r), ':']);
    
    rseed(r) = sum(1000 * r);
    Forest = IsolationForest(Data, NumTree,NumSub,rseed(r));

    [Mass, Nodes, tt] = IsolationEstimationNew(Data, Forest);
tt
%     Score = - mean(Mass, 2);
%     [B,I] = sort(Score, 'descend');
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

    T = 100;
    tic
    ResultNonneg = OnlineOptimiation(TransferData, YLabels', T);
    toc

    optionsTruncated.gradientUpdate = 'truncated';
    optionsTruncated.Sparsity = 4000;
    optionsTruncated.Cost = [1,1];
    tic
    ResultTuncated = OnlineOptimiationTG_SR(TransferData, YLabels', T, optionsTruncated);
    toc


    optionsSparseRecovery.gradientUpdate = 'sparse-recovery';
    optionsSparseRecovery.Cost = [100,0.001];
    optionsSparseRecovery.Sparsity = 4000;
    optionsSparseRecovery.SRratio = 0.40;
    tic
    ResultSparseRecovery = OnlineOptimiationTG_SR(TransferData, YLabels', T, optionsSparseRecovery);
    toc

%% Prepare data for visualization
T2 = 45;
NewLabels =    YLabels;
Fun = ResultTuncated.Unsupervised;
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
