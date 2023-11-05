function adjMatrix = threshold_adjMatrix(adjMatrix, conn_thr)
% threshold_adjMatrix - Threshold Connectivity Matrix
%
% Description:
%   The `threshold_adjMatrix` function thresholds a connectivity matrix by
%   retaining only the connections above a certain percentile of connection
%   strengths. The connections below this threshold are set to zero.
%
% Inputs:
%   - adjMatrix: The connectivity matrix to be thresholded.
%   - conn_thr: The percentile threshold (0 to 100) for connection strengths.
%
% Outputs:
%   - adjMatrix: The thresholded connectivity matrix.

    adjMatrix = adjMatrix .* (adjMatrix > prctile(adjMatrix(:), conn_thr));
    adjMatrix(isnan(adjMatrix)) = 0; 
    
end
