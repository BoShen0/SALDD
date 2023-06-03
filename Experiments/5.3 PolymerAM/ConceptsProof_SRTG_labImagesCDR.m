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
for r = 1:rounds
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

    optionsTruncated.Cost = [1,1];
    tic
    ResultTuncated2 = OnlineOptimiation(TransferData, YLabels, T, optionsTruncated);
    toc

    optionsSparseRecovery.gradientUpdate = 'sparse-recovery';
    optionsSparseRecovery.Cost = [100,0.001];
    optionsSparseRecovery.Sparsity = 4000;
    optionsSparseRecovery.SRratio =0.1;
    tic
    ResultSparseRecovery = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
    toc
    
    optionsSparseRecovery.SRratio =0.2;
    tic
    ResultSparseRecovery2 = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
    toc
    
    optionsSparseRecovery.SRratio =0.3;
    tic
    ResultSparseRecovery3 = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
    toc
    
    optionsSparseRecovery.SRratio =0.4;
    tic
    ResultSparseRecovery4 = OnlineOptimiationTG_SR(TransferData, YLabels, T, optionsSparseRecovery);
    toc
    
    AA(:,r) = cumsum(ResultTuncated.HumanFeedOutput(1:T,2)>0);
    BB(:,r) = cumsum(ResultSparseRecovery.HumanFeedOutput(1:T,2)>0); 
    CC(:,r) = cumsum(ResultNonneg.HumanFeedOutput(1:T,2)>0);
    DD(:,r) = cumsum(ResultNonneg.Unsupervised(1:T,2)>0);
    
    EE(:,r) = cumsum(ResultTuncated2.HumanFeedOutput(1:T,2)>0);
    FF(:,r) = cumsum(ResultSparseRecovery2.HumanFeedOutput(1:T,2)>0); 
    GG(:,r) = cumsum(ResultSparseRecovery3.HumanFeedOutput(1:T,2)>0); 
    HH(:,r) = cumsum(ResultSparseRecovery4.HumanFeedOutput(1:T,2)>0); 
end
tEnd = toc(tStart) 
%% plot setup

T2 =100;
errorBarSeq = 1:floor(T2/10):T2;

MeanAA = mean(AA(1:T2,:),2);
ErrorAA = std(AA(1:T2,:),0,2);

MeanBB = mean(BB(1:T2,:),2);
ErrorBB = std(BB(1:T2,:),0,2);

MeanCC = mean(CC(1:T2,:),2);
ErrorCC = std(CC(1:T2,:),0,2);

MeanDD = mean(DD(1:T2,:),2);
ErrorDD = std(DD(1:T2,:),0,2);

plot(MeanAA,'Color','blue')
hold on;
plot(MeanBB,'Color','red')
hold on;
plot(MeanCC,'Color',[0.9290 0.6940 0.1250])
hold on;
plot(MeanDD,'Color',[0.3010 0.7450 0.9330])
hold on;

errorbar(errorBarSeq,MeanAA(errorBarSeq),1*ErrorAA(errorBarSeq)/sqrt(10),...
    'Color','blue','LineStyle', 'none')
hold on;
errorbar(errorBarSeq,MeanBB(errorBarSeq),1*ErrorBB(errorBarSeq)/sqrt(10),...
    'Color','red','LineStyle', 'none')
hold on;
errorbar(errorBarSeq,MeanCC(errorBarSeq),1*ErrorCC(errorBarSeq)/sqrt(10),...
    'Color',[0.9290 0.6940 0.1250],'LineStyle', 'none')
hold on;
errorbar(errorBarSeq,MeanDD(errorBarSeq),1*ErrorDD(errorBarSeq)/sqrt(10),...
    'Color',[0.3010 0.7450 0.9330],'LineStyle', 'none')
hold off;

YMatrix1 = [MeanBB , MeanCC , MeanDD];
XMatrix1 = repmat(errorBarSeq',1,3);
YMatrix2 = YMatrix1(errorBarSeq,:);
DMatrix  = [ErrorBB, ErrorCC , ErrorDD];
DMatrix1 = 1*DMatrix(errorBarSeq,:)/sqrt(rounds);
% show the table results
[MeanDD(end,:),MeanCC(end,:),MeanAA(end,:),MeanBB(end,:)]
% 6.0000    8.7000   23.6000   23.5000
[ErrorDD(end,:),ErrorCC(end,:),ErrorAA(end,:),ErrorBB(end,:)]
% 1.1547    1.8288    6.8346    6.1509

% %% Prepare data for visualization
% T2 = 100;
% NewLabels =    YLabels;
% Fun = ResultSparseRecovery.HumanFeedOutput;
% for tt = 1:T2
% NewLabels(Fun(tt,1)) = YLabels(Fun(tt,1))+Fun(tt,2);
% end
% rng('default') % for fair comparison
% Y = tsne(TransferData,'Algorithm','exact','Distance','cosine');
% % r = 1  works good; donot change the code
% % rng('default') % for fair comparison
% % Y = tsne(Data,'Algorithm','exact','Distance','chebychev');
% % 
% % rng('default') % for fair comparison
% % Y = tsne(Data,'Algorithm','exact','Distance','euclidean');

