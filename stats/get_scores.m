function [Accuracy, Sensitivity, Specificity, ppv, npv] = get_scores(TP, TN, FP, FN, confidence_intervals)
% get_scores - Calculate Binary Classification Metrics
%
% Syntax:
%   [Accuracy, Sensitivity, Specificity, ppv, npv] = get_scores(TP, TN, FP, FN, confidence_intervals)
%
% Description:
%   The function `get_scores` calculates performance metrics for binary
%   classification models. It computes accuracy, sensitivity, specificity,
%   positive predictive value (PPV), and negative predictive value (NPV).
%   Optionally, it can also calculate confidence intervals for these metrics.
%
% Input:
%   - TP: Number of true positives (correctly predicted positive cases).
%   - TN: Number of true negatives (correctly predicted negative cases).
%   - FP: Number of false positives (incorrectly predicted positive cases).
%   - FN: Number of false negatives (incorrectly predicted negative cases).
%   - confidence_intervals (optional): Flag to compute confidence intervals.
%     Default is 1 (compute confidence intervals). Set to 0 to disable.
%
% Output:
%   - Accuracy: The accuracy of the classification model, i.e., the
%     proportion of correct predictions.
%   - Sensitivity: The sensitivity, also known as the true positive rate or
%     recall, measures the proportion of actual positive cases correctly
%     identified.
%   - Specificity: The specificity, also known as the true negative rate,
%     measures the proportion of actual negative cases correctly identified.
%   - PPV (Positive Predictive Value): The proportion of true positive
%     predictions among all positive predictions made by the model.
%   - NPV (Negative Predictive Value): The proportion of true negative
%     predictions among all negative predictions made by the model.
    
    if nargin < 5
        confidence_intervals = 1; 
    end 
    
    N = TP + TN + FP + FN; 
    
    if confidence_intervals
        
        CI = get_ci(TP + TN, N); 
        Accuracy = strjoin([num2str((TP + TN) / N) CI], " "); 

        CI = get_ci(TP, TP + FN);
        Sensitivity = strjoin([num2str(TP / (TP + FN)) CI], " "); 

        CI = get_ci(TN, TN + FP);
        Specificity = strjoin([num2str(TN / (TN + FP)) CI], " "); 
        
        CI = get_ci(TP, TP + FP); 
        ppv = strjoin([num2str(TP / (TP + FP)) CI], " "); 

        CI = get_ci(TN, TN + FN); 
        npv = strjoin([num2str(TN / (TN + FN)) CI], " "); 

    else 
        
        Accuracy = (TP + TN) / N; 
        
        Sensitivity = TP / (TP + FN); 

        Specificity = TN / (TN + FP); 
        
        ppv = TP / (TP + FP); 
        
        npv = TN / (TN + FN); 
        
    end 
 
end 

function CI = get_ci(x, n)
    [~, CI] = binofit(x, n); 
    CI = strjoin(["[", num2str(CI), "]"], ""); 
end 
