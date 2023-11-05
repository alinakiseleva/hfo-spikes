function patientStruct = buildElectrodeCommunities(patientStruct, plotting)

% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.


if nargin < 2
    plotting = true;
end

for ii = 1:length(patientStruct) %% == 1
    
    %%%%%%%
    % Build adjacency matrix
    %%%%%%%
    
    [connectFull,listFull] = pullConnectivityMatrix(patientStruct(ii)); % [matrix,names_of_the_channels]
 
    %%%%%%%
    % Community detection
    %%%%%%%
    
    % Retrieve spatial locations 
    
    leadLocations = patientStruct(ii).leadLocations; 
    
    
    listLL = leadLocations(:,1);
    [~, convertInds] = ismember(listFull,listLL);
    
    locsFull = cell2mat(leadLocations(convertInds,2:4)); %% list full order 
    % Test: assert(isequal(listFull,listLL(convertInds)'))
    

    [Ci,~,paramStruct] = modularity_dir_gravity(connectFull,[],locsFull);

    
    A = paramStruct.modMatrix; 
    [sigMatrix, ~, ~, zMatrix] = Sig_permTest(Ci, A, 1000);
    %isQualified = diag(zMatrix)' > 6;
    isQualified = diag(zMatrix)' > 3;
    
    numCl = length(sigMatrix);

    for jj = 1:numCl
        findInds = find(Ci == jj);

        patientStruct(ii).clusters(jj).clusterLeads = listFull(findInds);
        patientStruct(ii).clusters(jj).clusterInds = findInds;
    end
    

    patientStruct(ii).isQualified = isQualified; 
    patientStruct(ii).S = Ci;
    
    patientStruct(ii).listFull = listFull;
    patientStruct(ii).connectFull = connectFull;
    patientStruct(ii).zMatrix = diag(zMatrix);
    
    
    
    if plotting
        sprintf('Plotting communities for patient %d',ii)
        clf
        plotConnectivityMat(patientStruct(ii));
    end
    
 
    
end
