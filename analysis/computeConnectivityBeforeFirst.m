function condProbs = computeConnectivityBeforeFirst(leadList,epochsList,varargin)

% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.

%% Preamble


p = inputParser;
paramName = 'state';
defaultVal = 0;
addParameter(p,paramName,defaultVal)


parse(p,varargin{:})
myState = p.Results.state;

%% Onto the function



occurCount = zeros(length(leadList));
numSpikesMaster = zeros(length(leadList),1);

for kk = 1:length(epochsList)
    
    if myState
        if strcmpi(epochsList(kk).State,'awake');isAwake = 1;else; isAwake = 0;end
        if isequal(myState,'waking') && ~isAwake
            continue
        elseif isequal(myState,'sleeping') && isAwake
            continue
        end
    end

    if ~isempty(epochsList(kk).spikes)
        spk_order = epochsList(kk).spikes.spk_order{5};
        spk_time = spk_order(:,2:2:end);
        spk_time = cell2mat(spk_time);
        spk_leads = spk_order(:,1:2:end);

        %%%%%%
        % Remove spikes with 0 latency 
        currentCounter = 2;
        if ~isempty(spk_time)
            spikeInstantly = spk_time(currentCounter,:);
            % spikeInstantly = spikeInstantly == 0;
            % REMOVE SPIKES WITH LATENCY LESS THAN 3 ms 
            spikeInstantly = spikeInstantly < round(0.003 * epochsList(1).Fs);
            while any(spikeInstantly) && currentCounter < size(spk_leads,1)
                spk_leads(currentCounter,spikeInstantly) = {'VolCond'};
                siTemp = spikeInstantly;

                currentCounter = currentCounter + 1;
                spikeInstantly = spk_time(currentCounter,:);
                spikeInstantly = spikeInstantly == 0;
                spikeInstantly = spikeInstantly & siTemp;
            end

            [~, spikeByElec] = ismember(spk_leads,leadList); % spk_leads but with indexes 

            for ll = 1:length(leadList)
                tempElec = leadList{ll}; % take one channel 
                [~,totalSpikes] = retrieveSpikeRate(epochsList(kk).spikes,tempElec); % get the num of spikes, use the channel name
                numSpikesMaster(ll) = numSpikesMaster(ll) + totalSpikes; 

                instanceFollow = spikeByElec(2:end,:) == ll;
                instanceFollow = any(instanceFollow,1); % if this channel is in any column 

                for lll = find(~strcmpi(leadList,leadList{ll}))    

                    instanceLead = spikeByElec(1,:) == lll;

                    coOccurTemp = sum(and(instanceFollow,instanceLead)); % num of times for leading and following 
                    occurCount(ll,lll) = sum([occurCount(ll,lll) coOccurTemp]); % rows - follows, cols = leads 

                end 
            end
        end 
    end 
end

condProbs = occurCount ./ numSpikesMaster; %numSpikesMaster - all spikes, we get a matrix for temp cooccuring 



end
