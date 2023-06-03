clear
load('Isolet.mat')
% data are attribute values
% class is label where 1 represents anomaly
% data = normalize(data);
s = rng;
data  = normrnd(3,10,[1000,50]);


NumTree = 100; % number of isolation trees
NumSub = 2^10; % subsample size NumSub can be [2 4 8 16 32 64 128 256]
 r = 1
 rseed(r) = sum(100 * 10);
 Forest = IsolationForest(data, NumTree,NumSub,rseed(r));
 
 [Mass, Nodes, tt] = IsolationEstimationNew(data, Forest);
 Score = - mean(Mass, 2);
 Measure_AUC(Score, class)
 
% [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(class),Score,'true');
% plot(Xlog,Ylog) 
% xlabel('False positive rate'); ylabel('True positive rate');
% title('AUC')

 for i =1:NumTree
     check(i,1) = length(unique(Nodes{i}));
 end
 unique(check)
 sum(std(data ) ==0)