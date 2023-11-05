function [sigMatrix, Qmatrix, Qmatrix_r,zMatrix] = Sig_permTest(C, A, T)
%%
% This a function that uses the permutation test to calculate
% the significance of clusters in a given community structure
%%
% INPUT:
% "A" is a N-by-N weighted adjacency matrix
% "C" is a N-by-1 partition(cluster) vector
% "T" is # of random permutations
% OUTPUT:
% "sigMatrix" is the significance of all clusters
% "Qmatrix" is the modularity of the given partition(cluster)
% "Qmatrix_r" are the modularities of all random partitions
% 
% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.

num_node = size(A,1);
num_cl = numel(unique(C));
Qmatrix = Qvalue(C,A);
Qmatrix_r = zeros(T, num_cl, num_cl);
for i = 1:T
    C_r = C(randperm(num_node));
    Qmatrix_r(i,:,:) = Qvalue(C_r, A);
end
aveQ = zeros(num_cl);
stdQ = aveQ;
for i = 1:num_cl
    for j = 1:num_cl
        temp = squeeze(Qmatrix_r(:, i, j));        
        aveQ(i,j) = mean(temp);
        stdQ(i,j) = std(temp);
    end
end

sigMatrix = zeros(size(Qmatrix));
for iter = 1:T
    Q_random = squeeze(Qmatrix_r(iter,:,:));
    sigMatrix = sigMatrix + (Qmatrix < Q_random);
end
sigMatrix = sigMatrix / T;


zMatrix = (Qmatrix - aveQ) ./ stdQ; 

end


function Qmatrix = Qvalue(C, A)
%%
% This a function that calculates modularity
%%
if size(C,1) == 1
    C = C';
end
num_node = size(A,1);
cl_label = unique(C);
num_cl = numel(cl_label);
cl = zeros(num_node, num_cl);
for i = 1:num_cl
    cl(:, i) = C==cl_label(i);
end
Qmatrix = cl'*A*cl;
end