function [status, total] = get_status(results, outcome)
% get_status - Compute Classification Status and Totals
%
% Syntax:
%   [status, total] = get_status2(results, outcome)
%
% Description:
%   The function `get_status2` computes the classification status (True Positive,
%   False Positive, True Negative, False Negative) based on the model results
%   and the expected outcome. It also calculates the total counts for each status.
%
% Input:
%   - results: An array containing binary classification results.
%   - outcome: An array containing the expected outcome (ground truth).
%
% Output:
%   - status: A cell array containing the classification status for each data point.
%   - total: A structure containing the total counts for True Positives (TP),
%     False Positives (FP), True Negatives (TN), and False Negatives (FN).
    
    total = []; 
    status = {}; 
    
    status(results & outcome) = {'TP'}; 
    status(results & ~outcome) = {'FP'}; 
    status(~results & ~outcome) = {'TN'}; 
    status(~results & outcome) = {'FN'}; 

    status = status'; 
    
    inds = (outcome ~= -1); 
    
    total.TP = sum(results(inds) & outcome(inds)); 
    total.FP = sum(results(inds) & ~outcome(inds)); 
    total.TN = sum(~results(inds) & ~outcome(inds)); 
    total.FN = sum(~results(inds) & outcome(inds));
    
end 