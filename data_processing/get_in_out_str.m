function [instrength, outstrength] = get_in_out_str(patientStructFull)
% get_in_out_str - Calculate In-Strength and Out-Strength of Electrodes
%
% Description:
%   The `get_in_out_str` function calculates the in-strength and out-strength of
%   electrodes within the network represented by `patientStructFull`. It first
%   builds the electrode communities using `buildElectrodeCommunities`, and then
%   computes the in-strength and out-strength as the mean of the respective
%   adjacency matrix rows and columns.
%
% Inputs:
%   - patientStructFull: A structure containing patient EEG data and connectivity
%     information.
%
% Output:
%   - instrength: A row vector representing the in-strength of each electrode.
%   - outstrength: A row vector representing the out-strength of each electrode.
    
    patientStructFull = buildElectrodeCommunities(patientStructFull, false); 

    adjMatrix = patientStructFull.connectFull;
    adjMatrix = adjMatrix'; 
    adjMatrix(isnan(adjMatrix)) = 0; 

    instrength = mean(adjMatrix, 1);
    outstrength = mean(adjMatrix, 2)';

end 