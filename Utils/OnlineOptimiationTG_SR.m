% Copyright (c) 2021 Bo Shen
% This is function for online gradient descent, truncated gradient descent
% and OFS via sparse projection
% Reference: Wang, Jialei, et al. "Online feature selection and its applications." 
% IEEE Transactions on Knowledge and Data Engineering 26.3 (2013): 698-710.
function results = OnlineOptimiationTG_SR(TransferData, YLabels, T, options)
% This function is for feedback based anomaly discovery using online
% optimization. There are several inputs:
% TransferData: input features n * d matrix
% YLabels: ground truth label n dimensional vector (+1,-1)
% T: total budgets for human feedback
% options.gradientUpdate
% Outputs:
% to be determined

%% set up input variables
if nargin <= 3
    options = struct();
end
if ~isfield(options, 'gradientUpdate'); options.gradientUpdate = 'non-negative'; end
if ~isfield(options, 'Cost'); options.Cost = [1 1]; end
if ~isfield(options, 'Sparsity') && ~strcmp(options.gradientUpdate, 'non-negative')
    options.Sparsity = 4000; 
end
if strcmp(options.gradientUpdate, 'OFS') && ~isfield(options, 'Lambda')
    options.Lambda = 0.01; 
end

if strcmp(options.gradientUpdate, 'sparse-recovery') && ~isfield(options, 'SRratio')
    options.SRratio = 0.2; 
end

options

gradientUpdate = options.gradientUpdate;
Cost = options.Cost;
if isfield(options, 'Sparsity');  Sparsity = options.Sparsity; end 
if isfield(options, 'Lambda');    Lambda = options.Lambda; end 
if isfield(options, 'SRratio');    SRratio = options.SRratio; end 

%% Initial SetUp for Algoritm
weights = ones(size(TransferData,2),1);
Score_inital = - TransferData * weights;
[~,sortScore] = sort(Score_inital,'descend');
theta = weights;
D = 1:size(TransferData,1);
HumanFeedOutput = [];

%% Main Run for Gradient Descent
rng(1,'philox')
for iter = 1:T
weights = theta;
%%%%%%%%%%%% further gradient operation 
    if strcmp(gradientUpdate,'non-negative') 
        weights(weights<0) = 0; % non-negative weights
    elseif ~strcmp(gradientUpdate,'sparse-recovery')
        [~,sortTheta] = sort(theta,'descend');  % truncated gradient (top K values)
        weights(sortTheta((Sparsity+1):end)) = 0; % set weights in K+1:end to 0
        SparsityRatio(iter,1) = sum(weights>0);
        SparsityRatio(iter,2) = norm(weights)/norm(theta);
    else
        ThetaTemp = theta;
        ThetaTemp(ThetaTemp<0) = 0; % non-negative weights
        weights = ThetaTemp;
        ThetaSquare = ThetaTemp.^2; %
        [sortedThetaSquare,sortIndexThetaSquare] = sort(ThetaSquare,'descend');
        sumTheta = cumsum(sortedThetaSquare); % 
        %%%% there should be a better way to do that
        SparseRecoveryIndex = sum(sumTheta <= min( SRratio*sumTheta(end) ) );
        SparsityRecovery(iter) =  SparseRecoveryIndex;
%         disp(SparseRecoveryIndex)
        if  SparseRecoveryIndex >= Sparsity
        weights( sortIndexThetaSquare( (SparseRecoveryIndex+1):end ) ) = 0;
        else 
        weights( sortIndexThetaSquare( (Sparsity+1):end ) ) = 0;
        end
    end
    
Score = [];
Score = - TransferData(D,:) * weights;
[~,maxIndex] = max(Score);

tempIndex = D(maxIndex); % tempIndex: sample index selected 
HumanFeedOutput(iter,1) = tempIndex;
HumanFeedOutput(iter,2) = YLabels(tempIndex);
D(maxIndex) = [];  % remove the sample from the pool
%     theta = weights;
%%%%%%%%%%%% gradient update step
    if ~strcmp(gradientUpdate,'OFS') % anything other than 'OFS'
         if YLabels(tempIndex) == 1
         theta = theta  - Cost(1)/sqrt(iter) * YLabels(tempIndex) * TransferData(tempIndex,:)';
         else
         theta = theta  - Cost(2)/sqrt(iter) * YLabels(tempIndex) * TransferData(tempIndex,:)';
         end
    else
         if YLabels(tempIndex) == 1
         theta = (1 + Cost(1)*Lambda/sqrt(iter)) * theta - Cost(1)*Lambda/sqrt(iter) * YLabels(tempIndex) * TransferData(tempIndex,:)';
         else
         theta = (1 + Cost(2)*Lambda/sqrt(iter)) * theta - Cost(2)*Lambda/sqrt(iter) * YLabels(tempIndex) * TransferData(tempIndex,:)';
         end        
         theta = min(1, 1/(sqrt(Lambda)*norm(theta)) ) * theta;
    end
  
end
%% save the output
AA = [sortScore(1:T), YLabels(sortScore(1:T))];
results.HumanFeedOutput = HumanFeedOutput;
results.Unsupervised = AA;
if strcmp(gradientUpdate,'sparse-recovery')
    results.SparsityRecovery = SparsityRecovery;
end
if strcmp(gradientUpdate,'truncated')
    results.SparsityRatio = SparsityRatio;
end


end