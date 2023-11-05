function [connectFull,listFull] = pullConnectivityMatrix(patientStruct,varargin)
% Reference: Diamond JM, Chapeton JI, Theodore WH, Inati SK, Zaghloul KA. 
% The seizure onset zone drives state-dependent epileptiform activity in susceptible brain regions. 
% Clin Neurophysiol. 2019 Sep;130(9):1628-1641. doi: 10.1016/j.clinph.2019.05.032. Epub 2019 Jul 2. PMID: 31325676; PMCID: PMC6730646.

patientNum = num2str(patientStruct.Patient);

p = inputParser;
paramName = 'state';
defaultVal = 0;
addParameter(p,paramName,defaultVal)

parse(p,varargin{:})
myState = p.Results.state;

epochsList = patientStruct.epochsList; 
listFull = cell(1,0);

listFull = epochsList(1).spikes.rast_order';

connectFull = computeConnectivityBeforeFirst(listFull,epochsList,'state',myState);

end