function [mySpikeRate,totalSpikes,clipMinutes] = retrieveSpikeRate(spikes,elec)
% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.

    if ~isempty(spikes)
        clipMinutes = size(spikes.my_rast,1) / 1000 / 60;

        if nargin > 1

            myInd = find(strcmpi(elec,spikes.rast_order));

            if myInd
                totalSpikes = full(sum(spikes.my_rast(:,myInd)));
                mySpikeRate = totalSpikes / clipMinutes;

            else
                mySpikeRate = 0;
                totalSpikes = 0;
            end
        end

    else
                mySpikeRate = 0;
                totalSpikes = 0;
    end 

end
