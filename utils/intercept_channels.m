function intercept = intercept_channels(a, b)
% INTERCEPT_CHANNELS Find the intersection of two string arrays.
%
% Syntax:
%   intercept = intercept_channels(a, b)
%
% Description:
%   The `intercept_channels` function finds the intersection of two string arrays, `a` and `b`. It returns a new array `intercept` containing elements that are present in both `a` and `b`.
%
% Input:
%   - a: An array of strings.
%   - b: Another array of strings.
%
% Output:
%   - intercept: An array containing elements common to both `a` and `b`.

    intercept = []; 

    for i = 1:length(a)
        if count_matching_strings(split_hyphen_strings(a(i)), split_hyphen_strings(b)) > 0
            intercept = [intercept; a(i)]; 
        end     
    end 

end