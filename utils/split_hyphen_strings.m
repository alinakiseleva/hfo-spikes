function result = split_hyphen_strings(input_list)
% SPLIT_HYPHEN_STRINGS Split and reformat strings containing hyphens.
%
% Syntax:
%   result = split_hyphen_strings(input_list)
%
% Description:
%   The `split_hyphen_strings` function takes a cell array of strings as input.
%   It splits strings containing hyphens and reformats them based on certain criteria.
%
% Input:
%   - input_list: A cell array of strings to be processed.
%
% Output:
%   - result: A cell array of strings with hyphen-containing strings split and reformatted.

    result = {};
    for i = 1:numel(input_list)
        item = input_list{i};
        if contains(item, '-')
            parts = split(item, '-');           
            basestr = parts{1}(1:find(isletter(parts{1}), 1, 'last'));       
            result{end+1} = parts{1}; 
            result{end+1} = [basestr parts{2}];            
        else
            result{end+1} = item;
        end
    end
end

