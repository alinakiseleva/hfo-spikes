function chan_names = trim_ch_names(chan_names, del_strings)    
% trim_ch_names - Delete Substrings from Channel Names
%
% Description:
%   The `trim_ch_names` function removes specified substrings from a cell
%   array of channel names, providing cleaned channel names.
%
% Inputs:
%   - chan_names: A cell array of channel names.
%   - del_strings: A cell array of substrings to remove from channel names.
%
% Outputs:
%   - chan_names: A cell array with cleaned channel names.

    for  j = 1:length(del_strings) 
        del_string = del_strings{j}; 
        for i = 1:length(chan_names)
            del_symbs = []; 
            str_indx = strfind(chan_names{i}, del_string); 
            for del = str_indx
                del_symbs = [del_symbs, del:del+length(del_string)-1]; 
            end 
            chan_names{i}(del_symbs) = ''; 
        end 
    end 
    
end 