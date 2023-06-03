%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:8
    row = (78*(i-1) + 1):(78*(i-1) + 80);
    for j = 1:24   
        col = (80*(j-1) + 1):(80*j);
        DataIndex{24*(i-1)+j} = [row;col];
    end
end    
Anomaly1 = MetalR7(721:1280,541:620); % 541:620 is good; perhapes this is the 
% the only working case right now
for i=1:7
    row = (80*(i-1) + 1):(80*i);
    DataIndex{i+192} = [row+720;541:620];
end

DataMetal = MetalR7;
QueryIndex = ResultSparseRecovery.HumanFeedOutput(1:45,1);
for i = QueryIndex'
   DataMetal(DataIndex{i}(1,:),DataIndex{i}(2,:)) =255;
end
imshow(DataMetal)