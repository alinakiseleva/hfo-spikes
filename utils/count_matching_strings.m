function matching_count = count_matching_strings(array1, array2)
% COUNT_MATCHING_STRINGS Counts the number of matching strings between two cell arrays.
%
% Syntax:
%   matchingCount = count_matching_strings(array1, array2)
%
% Description:
%   The `count_matching_strings` function counts the number of strings that
%   match between two cell arrays, `array1` and `array2`. It checks each
%   element in `array1` and counts how many of them are found in `array2`.
%
% Input:
%   - array1: A cell array of strings to compare.
%   - array2: A cell array of strings for comparison.
%
% Output:
%   - matchingCount: The number of strings found in both `array1` and `array2`.

    matching_count = 0;

        for i = 1:length(array1)

            if any(strcmp(array1{i}, array2))
                matching_count = matching_count + 1;
            end

        end
    
end