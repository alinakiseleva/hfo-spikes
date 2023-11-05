function InstrOutstr = useConditionalforSOZPredict(patientStruct,varargin)
% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.

%%

p = inputParser;
paramName = 'state';
defaultVal = 0;
addParameter(p,paramName,defaultVal)

paramName = 'SOZtoNonSOZ';
defaultVal = true;
addParameter(p,paramName,defaultVal)

paramName = 'useQualified';
defaultVal = true; 
addParameter(p,paramName,defaultVal);

paramName = 'restrictT1';
defaultVal = false;
addParameter(p,paramName,defaultVal);


parse(p,varargin{:})
myState = p.Results.state;
SOZtoNonSOZ = p.Results.SOZtoNonSOZ;
restrictT1 = p.Results.restrictT1;
useQualified = p.Results.useQualified;


%% 

InstrOutstr = zeros(6,0);

for ii = 1:length(patientStruct)
    [connectFull,listFull] = pullConnectivityMatrix(patientStruct(ii));
    
    onsetElectrodes = patientStruct(ii).onsetElectrodes;
    
    isSOZ = ismember(listFull,onsetElectrodes);

    patientClusters = patientStruct(ii).clusters; 
    
    if useQualified; jInds = find(patientStruct(ii).isQualified);
    else; jInds = 1:length(patientClusters);
    end
        
  
    for jj = jInds         
        
        listCluster = patientClusters(jj).clusterLeads; 
        isCluster = ismember(listFull,listCluster);
        
        clusterIctal = isCluster & isSOZ; 
        clusterNonIctal = isCluster & ~isSOZ; 
        
        withinClusterIctal = isSOZ(isCluster);
        
        if restrictT1
            isT1Cluster = sum(withinClusterIctal) / length(withinClusterIctal) >= 0.1;
            if ~isT1Cluster; continue; end
        end
        
        
        if SOZtoNonSOZ
            
            if sum(clusterIctal) == 0 || sum(clusterNonIctal) == 0; continue; end
            
            rowColMean = zeros(2,length(isCluster));
            
            for ll = find(isCluster)
                
                isSOZCurrent = isSOZ(ll); 
                if isSOZCurrent  
                    interactIndices = clusterNonIctal;
                else 
                    interactIndices = clusterIctal;
                end
                
                currentRow = connectFull(ll,interactIndices);
                currentCol = connectFull(interactIndices,ll);
                            
                currentRow(isnan(currentRow)) = 0; 
                currentCol(isnan(currentCol)) = 0; 
              
                rowColMean(1,ll) = mean(currentRow);
                rowColMean(2,ll) = mean(currentCol);
                rowColMean(3,ll) = ll; 
                        
            end
            
            rowColMean(:,~isCluster) = [];
            
        else
            rowColMean = zeros(2,length(isCluster)); 
            for ll = find(isCluster)
                interactIndices = isCluster; 
                
                currentRow = connectFull(ll,interactIndices);
                currentCol = connectFull(interactIndices,ll);
                
                currentRow(isnan(currentRow)) = 0;
                currentCol(isnan(currentCol)) = 0;
                
                rowColMean(1,ll) = mean(currentRow);
                rowColMean(2,ll) = mean(currentCol);
                
                rowColMean(3,ll) = ll;
            end
            rowColMean(:,~isCluster) = [];
        end
        
        isCluster = listFull(isCluster);
        LcSortIC = zeros(size(isCluster));
        [~, sortLC] = sort(listCluster);
        [~, sortIC] = sort(isCluster);
        LcSortIC(sortLC) = sortIC; 
        
        rowColMean = rowColMean(:,LcSortIC); 
        withinClusterIctal = withinClusterIctal(LcSortIC);
   
        InstrOutstr = [InstrOutstr [rowColMean;withinClusterIctal; ...
            ii * ones(size(withinClusterIctal)); jj * ones(size(withinClusterIctal))]];
    end
end
