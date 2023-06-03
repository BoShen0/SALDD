function Features = Nodes2Binary(Nodes)
% 
% Function Nodes2Binary: transfer the nodes set to binary feature vectors
% 
% Inputs:
%     Nodes: A cell of trees
% 
% Outputs:
%     Features: A cell of binary features
% 
% Copyright by Bo Shen, May 22, 2021 (boshen@vt.edu).
% 
IndexNodesSet = [];

Features = cell(size(Nodes,1),1);

for i =1:size(Nodes,1)
     IndexNodesSet = unique(Nodes{i});
     IndexNodesSet(1) = [];  % to remove the first element 0
     Dict = Nodes{i};
     Temp_f = zeros(size(Dict,1), length(IndexNodesSet));
     for j = 1:size(Dict,1)
          % to find the position of Dict(j,:) in IndexNodeSet using
          % ismember
          [~,Locb] = ismember(Dict(j,:),IndexNodesSet); 
          Temp_f(j,Locb(Locb>0)) = 1;
     end
     Features{i} = Temp_f;
 end

end