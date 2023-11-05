function adjMatrix = get_adjMatrix(patientStructFull)
% get_adjMatrix - Generate an Adjacency Matrix for Electrode Communities
%
% Description:
%   The `get_adjMatrix` function calculates an adjacency matrix based on
%   electrode communities present in the `patientStructFull` structure. It
%   utilizes the electrode community information to represent the connections
%   between electrodes in the adjacency matrix.
%
% Inputs:
%   - patientStructFull: A structure containing information about electrode
%     communities and connectivity data.
%
% Output:
%   - adjMatrix: The adjacency matrix representing the relationships between
%     electrodes. 

    patientStructFull = buildElectrodeCommunities(patientStructFull, false); 

    adjMatrix = patientStructFull.connectFull;
    adjMatrix = adjMatrix'; 
    adjMatrix(isnan(adjMatrix)) = 0; 

end