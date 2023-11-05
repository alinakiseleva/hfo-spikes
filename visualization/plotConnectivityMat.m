function plotConnectivityMat(patientStruct,varargin)

% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.

%% Unpack 

listFull = patientStruct.listFull; 
connectFull = patientStruct.connectFull; %% ' 
% In our code, we have had influence relationships run from column to row. 
% This is actually not conventional. 
% For purposes of images for publication, we have transposed connectFull 
% so as to fit the convention. 
% In the future, I may go through all this code and have influence
% relationships run from row to column. 
% This way we will no longer have to transpose. 



p = inputParser;
addParameter(p, 'grayThreshold', connectFull);
addParameter(p, 'fontsize', 10);

parse(p,varargin{:})
grayThreshold = p.Results.grayThreshold;
fontsize = p.Results.fontsize;

S = patientStruct.S; 
isQualified = patientStruct.isQualified;
clusters = patientStruct.clusters; 


onsetElectrodes = patientStruct.onsetElectrodes;

clusterInds = cell(size(clusters));
clusterLeads = cell(size(clusters));

isT1Clust = zeros(size(clusters));

for jj = 1:length(clusters)
    clusterInds{jj} = clusters(jj).clusterInds;
    clusterLeads{jj} = clusters(jj).clusterLeads;
    
    isSOZ = ismember(clusterLeads{jj},onsetElectrodes); 
    isT1Clust(jj) = sum(isSOZ) / length(isSOZ) >= .1;
end
isSOZ = ismember(listFull,onsetElectrodes);




%% Plot matrix 

% h_im = imagesc(connectMat);
[~,inds] = sort(S,'ascend');

imageClusters = connectFull(inds,inds);
h_im = imagesc(imageClusters);
listFull = listFull(inds);
grayThreshold = grayThreshold(inds,inds);
isSOZ = isSOZ(inds);

grid('off')

% colorbar
set(gca,'ytick',1:1:length(listFull))
set(gca,'yticklabel',listFull,'fontsize',fontsize)
set(gca,'xtick',1:1:length(listFull))
set(gca,'xticklabel',listFull,'fontsize',fontsize)
set(gca,'xaxisLocation','top', 'XTickLabelRotation', 90)

set(h_im,'alphadata',grayThreshold > 0)
set(gca,'Color',[0.75 0.75 0.75])
set(gca,'TickLength',[0 0])


ticklabels = get(gca,'YTickLabel');
ticklabelsNew = cell(size(ticklabels));
for ii = 1:length(ticklabels)
    if isSOZ(ii)
        ticklabelsNew{ii} = ['\color[rgb]{.0549,.733,.7137}' ticklabels{ii}];
    else
        ticklabelsNew{ii} = ['\color[rgb]{0,0,0}' ticklabels{ii}];
    end
end
set(gca, 'YTickLabel', ticklabelsNew);

box off
axis equal tight

%% Plot clusters 
sz = size(isQualified); 
if sz(1) > sz(2); isQualified = isQualified'; end

colorBlue = [153 204 255] / 255;
colorRed = [237 125 129] / 255;

for jj = find(isQualified)

    pos1 = find(inds == clusterInds{jj}(1)) - 0.5;
    pos2 = find(inds == clusterInds{jj}(end)) - pos1 + 0.5;
    
    if isT1Clust(jj) 
        rectangleColor = colorRed;
        colorRed = colorRed * .7; 
    else
        rectangleColor = colorBlue; 
        colorBlue = colorBlue * .7; 
    end
    
    rectangle('Position',[pos1 pos1 pos2 pos2],'EdgeColor',rectangleColor,'linewidth',1);
    
end

drawnow

