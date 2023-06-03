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
%  imshow(MetalR7(721:1280,581:660))
%  imshow(MetalR7(711:790,1291:1530)) 
%  Data = randi([3, 4], [2000,40]);
%% isolation forest 
rounds = 10; % rounds of repeat
% parameters for iForest
NumTree = 100; % number of isolation trees
NumSub = 2^8; % subsample size
NumDim = size(Data, 2); % do not perform dimension sampling 
 
auc = zeros(rounds, 1);
mtime = zeros(rounds, 2);
rseed = zeros(rounds, 1);

clear AA BB CC DD;
for r = 1:rounds
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
    AA(:,r) = cumsum(ResultTuncated.HumanFeedOutput(1:T,2)>0);
    BB(:,r) = cumsum(ResultSparseRecovery.HumanFeedOutput(1:T,2)>0); 
    CC(:,r) = cumsum(ResultNonneg.HumanFeedOutput(1:T,2)>0);
    DD(:,r) = cumsum(ResultNonneg.Unsupervised(1:T,2)>0);
end

%% plot setup

T2 =45;
errorBarSeq = 1:5:T2;

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
DMatrix  = [ErrorBB , ErrorCC , ErrorDD];
DMatrix1 = DMatrix(errorBarSeq,:)/sqrt(rounds);
%%%%%sparse recovery: sparsity 4000, cost [100,0.001], SRratio 0.3 or 0.4; it works well 
