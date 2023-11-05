function [add_chs, exclude_chs] = compare_channels(listFull, chan_names) 
% compare_channels - Compare channel names to a reference list
%
% Syntax:
%   [add_chs, exclude_chs] = compare_channels(listFull, chan_names)
%
% Description:
%   The `compare_channels` function compares a list of channel names to a reference
%   list (`listFull`) and identifies channels to add and exclude.
%
% Inputs:
%   - listFull: A reference list of channel names.
%   - chan_names: A cell array of channel names to compare.
%
% Outputs:
%   - add_chs: Indices of channels to add to the reference list.
%   - exclude_chs: Indices of channels to exclude from the reference list.

    exclude_chs = []; 
    add_chs = []; 

    ch_idxs = zeros(length(chan_names), 1); 

    for i = 1:length(chan_names)
        ch_id = find(strcmp(listFull, chan_names{i})); 
        if ~isempty(ch_id)
            ch_idxs(i) = ch_id;
        end 
    end 

    if length(ch_idxs) == length(listFull) && all(ch_idxs == [1:length(listFull)]')
        disp('channels match')

    elseif length(chan_names) < length(listFull)
        add_chs = ones(length(listFull), 1); 
        add_chs(ch_idxs) =  0; 
        add_chs = find(add_chs == 1); 

    elseif length(chan_names) > length(listFull)
        exclude_chs = find(ch_idxs == 0); 

    else
        if length(ch_idxs) == length(listFull)
            warning('Different channels used: ')
            disp(chan_names)
            disp('Using: ')
            disp(listFull)
            chan_names = listFull; 
        else 
            error('Different channels used')
        end 
    end 
end 